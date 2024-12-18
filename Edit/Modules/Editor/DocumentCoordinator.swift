import Foundation

import ChimeKit
import DocumentContent
import Highlighting
import SyntaxService
import TextSystem
import Theme

@MainActor
public final class DocumentCoordinator<Service: TokenService> {
	typealias StorageDispatcher = TextStorageDispatcher<TextViewSystem.Version>

	public let textSystem: TextViewSystem
	public let highlighter: Highlighter<Service>
	private let syntaxService: SyntaxService
	private let layoutBuffer = LayoutInvalidationBuffer()
	private let dispatcher: StorageDispatcher
	private let sourceViewController = SourceViewController()
	public let editorContentController: EditorContentViewController
	private let languageDataStore = LanguageDataStore.global

	public init(statusBarVisible: Bool) {
		self.textSystem = TextViewSystem(textView: sourceViewController.textView)

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

		let textView = sourceViewController.textView

		textSystem.willLayoutHandler = layoutBuffer.willLayout
		textSystem.didLayoutHandler = layoutBuffer.didLayout

		// default to something sensible
		sourceViewController.mutationFilter = languageDataStore.profile(for: .plainText).mutationFilter
		
		sourceViewController.shouldChangeTextHandler = { [dispatcher] in
			dispatcher.textView(textView, shouldChangeTextIn: $0, replacementString: $1)
		}

		sourceViewController.selectionChangedHandler = { [editorContentController] in
			editorContentController.selectedRanges = $0
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
	}

	public func documentContextChanged(from oldContext: DocumentContext, to newContext: DocumentContext) {
		syntaxService.documentContextChanged(from: oldContext, to: newContext)
		highlighter.documentContextChanged(from: oldContext, to: newContext)

		sourceViewController.mutationFilter = languageDataStore.profile(for: newContext.uti).mutationFilter
	}
}
