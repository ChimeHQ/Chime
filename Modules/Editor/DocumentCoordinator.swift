import Foundation
import UniformTypeIdentifiers

import ChimeKit
import DocumentContent
import Highlighting
import IBeam
import SyntaxService
import TextSystem
import Theme

@MainActor
public let sharedLanguageStore = LanguageDataStore()

@MainActor
public final class DocumentCoordinator<Service: TokenService> {
	typealias CursorTextSystem = TransformingTextSystem<TextViewSystem.Version>
	typealias FilterTextSystem = CursorTextSystem.TextFormationInterfaceType
	
	private let cursorCoordinator: TextSystemCursorCoordinator<CursorTextSystem>
	private let languageDataStore: LanguageDataStore = sharedLanguageStore
	private let layoutBuffer = LayoutInvalidationBuffer()
	private let mutationFilterStore = MutationFilterStore<FilterTextSystem>()
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
		self.whitespaceCalculator = WhitespaceCalculator(textSystem: textSystem)
		
		let monitors = [
			textSystem.storageMonitor,
			syntaxService.storageMonitor,
			highlighter.storageMonitor
		]

		let storage = textSystem.storage
			.relaying(to: monitors)

		let sourceView = sourceViewController.sourceView
		let cursorTextSystem = CursorTextSystem(
			textView: sourceView,
			storage: storage,
			whitespaceCalculator: whitespaceCalculator
		)

		self.cursorCoordinator = TextSystemCursorCoordinator(
			textView: sourceView,
			system: cursorTextSystem
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
		cursorCoordinator.cursorState.textSystem.filter = mutationFilterStore.filter(for: uti)
	}

	public func refresh() {
		highlighter.invalidate(.all)
	}
}
