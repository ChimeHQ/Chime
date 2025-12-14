import Foundation
import UniformTypeIdentifiers

import ChimeKit
import DocumentContent
import Highlighting
import IBeam
import SourceView
import SyntaxService
import TextFormation
import TextSystem
import Theme

final class DocumentFilterProvider {
	let filterStore: MutationFilterStore<TextFormationInterfaceAdapter>
	var uti: UTType

	init(filterStore: MutationFilterStore<TextFormationInterfaceAdapter>, uti: UTType) {
		self.filterStore = filterStore
		self.uti = uti
	}

	func createFilter() -> any Filter<TextFormationInterfaceAdapter> {
		return filterStore.filter(for: uti) ?? CompositeFilter(filters: [])
	}
}

@MainActor
public final class DocumentCoordinator<Service: TokenService> {
	private let cursorCoordinator: TextSystemCursorCoordinator<IBeamInterfaceAdapter>
	private let languageDataStore: LanguageDataStore = LanguageDataStore()
	private let layoutBuffer = LayoutInvalidationBuffer()
	private let mutationFilterStore = MutationFilterStore<TextFormationInterfaceAdapter>()
	private let filterProvider: DocumentFilterProvider
	private let sourceViewController = SourceViewController()
	private let syntaxService: SyntaxService
	private let whitespaceCalculator: WhitespaceCalculator

	public let textSystem: TextViewSystem
	public let highlighter: Highlighter<Service>
	public let editorContentController: EditorContentViewController

	public init(statusBarVisible: Bool) {
		self.textSystem = TextViewSystem(textView: sourceViewController.sourceView)

		self.editorContentController = EditorContentViewController(
			textSystem: textSystem,
			sourceViewController: sourceViewController,
			statusBarVisible: statusBarVisible
		)

		self.syntaxService = SyntaxService(textSystem: textSystem, languageDataStore: languageDataStore)
		self.highlighter = Highlighter(textSystem: textSystem, syntaxService: syntaxService)

		let monitors = [
			textSystem.storageMonitor,
			syntaxService.storageMonitor,
			highlighter.storageMonitor
		]

		let storage = textSystem.storage
			.relaying(to: monitors)

		self.whitespaceCalculator = WhitespaceCalculator(textSystem: textSystem, storage: storage)

		let sourceView = sourceViewController.sourceView

		let filterProvider = DocumentFilterProvider(filterStore: mutationFilterStore, uti: .plainText)

		let adapter = IBeamInterfaceAdapter(
			textView: sourceView,
			storage: storage,
			whitespaceCalculator: whitespaceCalculator,
			filterProvider: { filterProvider.createFilter() }
		)

		self.filterProvider = filterProvider

		self.cursorCoordinator = TextSystemCursorCoordinator(
			textView: sourceView,
			system: adapter
		)

		textSystem.willLayoutHandler = layoutBuffer.willLayout
		textSystem.didLayoutHandler = layoutBuffer.didLayout

		sourceView.cursorOperationHandler = cursorCoordinator.mutateCursors(with:)
		sourceView.operationProcessor = { [cursorCoordinator] in
			do {
				try cursorCoordinator.processOperation($0)
			} catch {
				print("failed to process input operation: \(error)")
				return false
			}

			return true
		}

		sourceViewController.selectionChangedHandler = { [editorContentController, cursorCoordinator] in
			editorContentController.cursors = cursorCoordinator.cursorState.cursorSet
		}

		syntaxService.invalidationHandler = { [highlighter] in
			highlighter.invalidate(textTarget: $0)
		}

		layoutBuffer.handler = { [highlighter] in
			highlighter.visibleContentDidChange()
		}

		editorContentController.contentVisibleRectChanged = { [layoutBuffer] _ in
			layoutBuffer.contentVisibleRectChanged()
		}

		languageDataStore.configurationLoaded = { [weak syntaxService, weak highlighter] name in
			syntaxService?.languageConfigurationChanged(for: name)
			highlighter?.name = name
		}

		// default to something sensible
		updateTextProcessing(with: .plainText)
	}

	public func documentContextChanged(from oldContext: DocumentContext, to newContext: DocumentContext) {
		syntaxService.documentContextChanged(from: oldContext, to: newContext)
		highlighter.documentContextChanged(from: oldContext, to: newContext)

		updateTextProcessing(with: newContext.uti)
	}

	private func updateTextProcessing(with uti: UTType) {
		self.filterProvider.uti = uti
	}

	public func refresh() {
		highlighter.invalidate(.all)
	}
}
