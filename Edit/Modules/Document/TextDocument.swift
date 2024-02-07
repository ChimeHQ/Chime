import AppKit
import SwiftUI
import OSLog

import ChimeKit
import ContainedDocument
import DocumentContent
import Editor
import ExtensionHost
import Highlighting
import ProcessEnv
import ProjectWindow
import SyntaxService
import TextStory
import TextSystem
import Theme
import Utility

@MainActor
public final class TextDocument: ContainedDocument<Project> {
	typealias StorageDispatcher = TextStorageDispatcher<TextViewSystem.Version>

	private let editorContentController: EditorContentViewController
	private let sourceViewController: SourceViewController
	private lazy var projectWindowController = makeProjectWindowController(
		contentViewController: editorContentController,
		context: state.context
	)

	private let syntaxService: SyntaxService
	private let storageDispatcher: StorageDispatcher
	private var isClosing = false
	private let logger = Logger(type: TextDocument.self)
	private let highlighter: Highlighter<ExtensionRouter.TokenService>
	public let textSystem: TextViewSystem
	public var stateChangedHandler: (DocumentState, DocumentState) -> Void = { _, _ in }
	public let layoutBuffer = LayoutInvalidationBuffer()

	private var state: DocumentState {
		didSet { stateUpdated(oldValue) }
	}

	override init() {
		self.sourceViewController = SourceViewController()
		self.textSystem = TextViewSystem(textView: sourceViewController.textView)
		self.syntaxService = SyntaxService(textSystem: textSystem, languageDataStore: LanguageDataStore.global)
		self.highlighter = Highlighter(textSystem: textSystem, syntaxService: syntaxService)
		self.state = DocumentState(contentId: textSystem.contentIdentity)
		self.editorContentController = EditorContentViewController(textSystem: textSystem, sourceViewController: sourceViewController)
		let dispatcher = StorageDispatcher(storage: textSystem.storage, monitors: [
			textSystem.storageMonitor,
			syntaxService.storageMonitor,
			highlighter.storageMonitor
		])

		self.storageDispatcher = dispatcher

	    super.init()

		let textView = sourceViewController.textView

		sourceViewController.shouldChangeTextHandler = {
			dispatcher.textView(textView, shouldChangeTextIn: $0, replacementString: $1)
		}

		sourceViewController.selectionChangedHandler = { [editorContentController] in
			editorContentController.selectedRanges = $0
		}

		sourceViewController.willLayoutHandler = { [layoutBuffer] in layoutBuffer.willLayout() }
		sourceViewController.didLayoutHandler = { [layoutBuffer] in layoutBuffer.didLayout() }

		syntaxService.invalidationHandler = { [highlighter] in
			highlighter.invalidate(textTarget: $0)
		}

		layoutBuffer.handler = { [highlighter] in
			highlighter.visibleContentDidChange()
		}

		editorContentController.contentVisibleRectChanged = { [layoutBuffer] _ in
			layoutBuffer.contentVisibleRectChanged()
		}

		LanguageDataStore.global.configurationLoaded = { [weak syntaxService] in
			syntaxService?.languageConfigurationChanged(for: $0)
		}
	}

	public var context: DocumentContext {
		state.context
	}

	public override class var autosavesInPlace: Bool {
		return true
	}

	public override func makeWindowControllers() {
		precondition(windowControllers.isEmpty)

		addWindowController(projectWindowController)
	}

	public override func data(ofType typeName: String) throws -> Data {
		// Insert code here to write your document to data of the specified type, throwing an error in case of failure.
		// Alternatively, you could remove this method and override fileWrapper(ofType:), write(to:ofType:), or write(to:ofType:for:originalContentsURL:) instead.
		throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
	}

	public override func read(from url: URL, ofType typeName: String) throws {
		try MainActor.assumeIsolated {
			let config = state.context.configuration
			let theme = projectWindowController.theme
			let context = Theme.Context(window: projectWindowController.window)
			let attrs = theme.typingAttributes(tabWidth: config.tabWidth, context: context)

			try textSystem.reload(from: url, attributes: attrs)

			let newContentId = textSystem.contentIdentity

			self.state.update(url: url, typeName: typeName, contentId: newContentId)
		}
	}

	public override func save(
		to url: URL,
		ofType typeName: String,
		for saveOperation: NSDocument.SaveOperationType,
		completionHandler: @escaping (Error?) -> Void
	) {
		super.save(to: url, ofType: typeName, for: saveOperation, completionHandler: {
			let newTypeName = (try? url.resourceValues(forKeys: [.typeIdentifierKey]).typeIdentifier) ?? typeName

			self.state.update(url: url, typeName: newTypeName)

			completionHandler($0)
		})
	}

	public override func close() {
		// Closing removes the project, which results in a state mutation and normally kicks off all kinds of work
		self.isClosing = true

		super.close()
	}

	public override var fileURL: URL? {
		didSet {
			// this can be set on a non-main thread
			DispatchQueue.main.asyncUnsafe {
				MainActor.assumeIsolated {
					self.state.update(url: self.fileURL)
				}
			}
		}
	}
}

extension TextDocument {
	private func stateUpdated(_ oldValue: DocumentState) {
		if oldValue == state || isClosing {
			return
		}

		logger.debug("document state changed")

		syntaxService.documentContextChanged(from: oldValue.context, to: state.context)
		highlighter.documentContextChanged(from: oldValue.context, to: state.context)

		stateChangedHandler(oldValue, state)
	}
}

extension TextDocument: ProjectDocument {
	public var projectState: ProjectState? {
		get { projectWindowController.state }
		set {
			self.state.updateProjectContext(newValue?.context)
			projectWindowController.state = newValue
		}
	}

	public var defaultProjectRoot: URL? {
		if ProcessInfo.processInfo.isSandboxed {
			return fileURL
		}

		// we cannot do this when sandboxed
		return fileURL?.deletingLastPathComponent()
	}

	public func willRemoveDocument() {
	}
	
	public func didCompleteOpen() {
	}
}

extension TextDocument {
	public func updateApplicationService(_ service: ExtensionRouter) {
		do {
			projectWindowController.symbolQueryService = try projectContext.flatMap { try service.symbolService(for: $0) }
		} catch {
			logger.error("Failed to update symbolService: \(error, privacy: .public)")
		}

		do {
			let docService = try service.documentService(for: context)

			self.highlighter.tokenService = try docService?.tokenService
		} catch {
			logger.error("Failed to create new document service connection: \(error, privacy: .public)")
		}
	}

	public func invalidateTokens(_ target: TextTarget) {
		highlighter.invalidate(textTarget: target)
	}
}

extension TextDocument {
	private func tokenStyle(for name: String) -> [NSAttributedString.Key : Any] {
		let theme = projectWindowController.theme
		let context = Theme.Context(window: projectWindowController.window)

		return theme.syntaxStyle(for: name, context: context)
	}
}
