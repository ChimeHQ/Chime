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
public final class DocumentCoordinator<Service: TokenService> {
	typealias StorageDispatcher = TextStorageDispatcher<TextViewSystem.Version>

	private let syntaxService: SyntaxService
	private let layoutBuffer = LayoutInvalidationBuffer()
	private let dispatcher: StorageDispatcher
	private let sourceViewController = SourceViewController()
	private let cursorCoordinator: TextSystemCursorCoordinator<TransformingTextSystem>
	private let languageDataStore = LanguageDataStore.global

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

		self.dispatcher = StorageDispatcher(storage: textSystem.storage, monitors: [
			textSystem.storageMonitor,
			syntaxService.storageMonitor,
			highlighter.storageMonitor
		])

		let sourceView = sourceViewController.sourceView

		self.cursorCoordinator = TextSystemCursorCoordinator(
			textView: sourceView,
			system: TransformingTextSystem(textView: sourceView)
		)

		textSystem.willLayoutHandler = layoutBuffer.willLayout
		textSystem.didLayoutHandler = layoutBuffer.didLayout
		
		sourceViewController.shouldChangeTextHandler = { [dispatcher] in
			dispatcher.textView(sourceView, shouldChangeTextIn: $0, replacementString: $1)
		}

		sourceView.cursorOperationHandler = cursorCoordinator.mutateCursors(with:)
		sourceView.operationProcessor = cursorCoordinator.processOperation

		sourceViewController.selectionChangedHandler = { [editorContentController, cursorCoordinator] in
			// this is potentially very expensive
			let ranges = cursorCoordinator.cursorState.cursors.map { $0.textRange }

			editorContentController.selectedRanges = ranges
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

		languageDataStore.configurationLoaded = { [weak syntaxService] in
			syntaxService?.languageConfigurationChanged(for: $0)
		}

		// default to something sensible
		updateMutationFilter(with: .plainText)
	}

	public func documentContextChanged(from oldContext: DocumentContext, to newContext: DocumentContext) {
		syntaxService.documentContextChanged(from: oldContext, to: newContext)
		highlighter.documentContextChanged(from: oldContext, to: newContext)

		updateMutationFilter(with: newContext.uti)
	}

	private func updateMutationFilter(with uti: UTType) {
		cursorCoordinator.cursorState.textSystem.filter = languageDataStore.profile(for: uti).mutationFilter
	}
}
