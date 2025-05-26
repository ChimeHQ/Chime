import AppKit
import SwiftUI
import OSLog

import ChimeKit
import ContainedDocument
import DocumentContent
import Editor
import ExtensionHost
import ProcessEnv
import ProjectWindow
import TextStory
import TextSystem
import Theme

public final class TextDocument: ContainedDocument<Project> {
	private lazy var projectWindowController = makeProjectWindowController(
		contentViewController: coordinator.editorContentController,
		model: windowModel
	)

	private var isClosing = false
	private let logger = Logger(type: TextDocument.self)
	public var stateChangedHandler: (DocumentState, DocumentState) -> Void = { _, _ in }
	private let windowModel: WindowStateModel
	private let coordinator: DocumentCoordinator<ExtensionRouter.TokenService>

	private var state: DocumentState {
		didSet { stateUpdated(oldValue) }
	}

	override init() {
		self.coordinator = DocumentCoordinator(statusBarVisible: true)
		self.state = DocumentState(contentId: coordinator.textSystem.contentIdentity)

		self.windowModel = WindowStateModel(
			context: state.context,
			themeStore: ProjectDocumentController.sharedController.themeStore
		)

	    super.init()

		// everything about this isn't great
		windowModel.themeUpdated = { [weak self] in
			self?.updateTheme($0)
		}
	}

	public var context: DocumentContext {
		state.context
	}

	public var textSystem: TextViewSystem {
		coordinator.textSystem
	}

	public override class var autosavesInPlace: Bool {
		return true
	}

	public override func makeWindowControllers() {
		precondition(windowControllers.isEmpty)

		addWindowController(projectWindowController)
	}

	public override func write(to url: URL, ofType typeName: String) throws {
		try MainActor.assumeIsolated {
			try textSystem.write(to: url)
		}
	}

	public override func read(from url: URL, ofType typeName: String) throws {
		try MainActor.assumeIsolated {
			let config = state.context.configuration
			let theme = windowModel.currentTheme
			let context = Query.Context(window: projectWindowController.window)
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

		coordinator.documentContextChanged(from: oldValue.context, to: state.context)

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

			coordinator.highlighter.tokenService = try docService?.tokenService
		} catch {
			logger.error("Failed to create new document service connection: \(error, privacy: .public)")
		}
	}

	public func invalidateTokens(_ target: TextTarget) {
		coordinator.highlighter.invalidate(textTarget: target)
	}
}

extension TextDocument {
	private func updateTheme(_ theme: Theme) {
		// touching projectWindowController here seems to cause problems...

		let config = state.context.configuration
		let context = Query.Context(window: nil)
		let attrs = theme.typingAttributes(tabWidth: config.tabWidth, context: context)

		textSystem.themeChanged(attributes: attrs)
		coordinator.highlighter.updateTheme(theme, context: context)
	}
}

extension TextDocument {
	@IBAction func refresh(_ sender: Any?) {
		coordinator.refresh()
	}
}
