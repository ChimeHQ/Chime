import AppKit
import UniformTypeIdentifiers

import ContainedDocument

public final class ProjectDocumentController: ContainedDocumentController<ProjectModel> {
	private(set) var projects = Set<ProjectModel>()
	private var restoringSet = Set<NSDocument>()
	private lazy var openPanelAccessoryViewController = OpenPanelAccessoryViewController()

	public var projectRemovedHandler: (ProjectModel) -> Void = { _ in }

	public override init() {
		super.init()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public override func removeDocument(_ document: NSDocument) {
		switch document {
		case let doc as BaseDocument:
			if let proj = doc.project {
				doc.willRemoveDocument()

				closeProjectIfRequired(proj)
			}
		default:
			break
		}

		super.removeDocument(document)

		// I don't *think* this is necessary, but it is a pretty easy
		// safety check. Just do it after calling super to be sure.
		restoringSet.remove(document)

		updateWindowMenu()
	}

	public override func beginOpenPanel(_ openPanel: NSOpenPanel, forTypes inTypes: [String]?, completionHandler: @escaping (Int) -> Void) {
		openPanel.treatsFilePackagesAsDirectories = true
		openPanel.showsHiddenFiles = false
		openPanel.canChooseDirectories = true

		openPanelAccessoryViewController.openPanel = openPanel

		openPanel.accessoryView = openPanelAccessoryViewController.view
		openPanel.isAccessoryViewDisclosed = true

		let fullTypes = (inTypes ?? []) + [UTType.text.identifier, UTType.data.identifier]

		super.beginOpenPanel(openPanel, forTypes: fullTypes, completionHandler: { (code) in
			completionHandler(code)
		})
	}

	public override func makeUntitledDocument(ofType typeName: String) throws -> NSDocument {
		let doc = try super.makeUntitledDocument(ofType: typeName)

		handleNewDocument(doc)

		return doc
	}

	public override func makeDocument(withContentsOf url: URL, ofType typeName: String) throws -> NSDocument {
		let doc = try super.makeDocument(withContentsOf: url, ofType: typeName)

		if let doc = doc as? DirectoryDocument {
			setupDirectoryDocumentIfNeeded(doc, for: url)
		}

		handleNewDocument(doc)

		return doc
	}

	public override func makeDocument(for urlOrNil: URL?, withContentsOf contentsURL: URL, ofType typeName: String) throws -> NSDocument {
		let doc = try super.makeDocument(for: urlOrNil, withContentsOf: contentsURL, ofType: typeName)

		// To suppress recents, we need to know which documents are being restored.
		restoringSet.insert(doc)

		handleNewDocument(doc)

		return doc
	}

	public override func noteNewRecentDocument(_ document: NSDocument) {
		if let doc = document as? BaseDocument {
			if doc.project != nil || restoringSet.contains(document) {
				return
			}
		}

		updateWindowMenu()
		super.noteNewRecentDocument(document)
	}

	private func handleOpen(result: OpenDocumentResult, display: Bool, completionHandler: (OpenDocumentResult) -> Void) {
		guard case .success((let doc, let alreadyOpen)) = result else {
			completionHandler(result)
			return
		}

		if alreadyOpen == false {
			doc.makeWindowControllers()
		}

		associateDefaultProjectIfNeeded(to: doc)

		if display {
			doc.showWindows()
		}

		completionHandler(result)
	}

	public override func reopenDocument(for urlOrNil: URL?, withContentsOf contentsURL: URL, display displayDocument: Bool, completionHandler: @escaping (NSDocument?, Bool, Error?) -> Void) {
		super.reopenDocument(for: urlOrNil, withContentsOf: contentsURL, display: displayDocument) {doc, alreadyOpen, error in
			completionHandler(doc, alreadyOpen, error)

			if let doc = doc {
				// now that this is complete, we have setup the document enough to
				// actually decide if we should note it as recent
				self.restoringSet.remove(doc)
				self.noteNewRecentDocument(doc)
			}
		}
	}

	public override func openDocument(withContentsOf url: URL, display displayDocument: Bool, completionHandler: @escaping (OpenDocumentResult) -> Void) {
		// If the user attempts to re-open the directory of an already-open project, we just want to act like they actually were opening the frontmost document.
		if let window = frontmostWindow(for: url) {
			let doc = window.windowController?.document as! NSDocument

			completionHandler(.success((doc, true)))

			return
		}

		// Open the document like normal, but do not display. This gives us the chance to swap
		// out the directory document UI if needed
		super.openDocument(withContentsOf: url, display: false) { result in
			self.handleOpen(result: result, display: displayDocument, completionHandler: completionHandler)
		}
	}

	private func setupDirectoryDocumentIfNeeded(_ document: DirectoryDocument, for url: URL) {
		let project = getOrAddProject(for: url)

		document.project = project
	}

	func associateDefaultProjectIfNeeded(to document: NSDocument) {
		guard let doc = document as? BaseDocument else { return }
		guard doc.project == nil else { return }
		guard let containingURL = document.fileURL?.deletingLastPathComponent() else { return }

		let project = getOrAddProject(for: containingURL)

		associateDocument(doc, to: project)
	}

	public override func encodeRestorableState(with coder: NSCoder, for document: NSDocument) {
		guard let doc = document as? BaseDocument else { return }

		if let data = doc.project?.url.fileBookmarkData() {
			coder.encode(data, forKey: ProjectDocumentController.bookmarkDataKey)
		}
	}

	public override func restoreState(with coder: NSCoder, for document: NSDocument) {
		guard let url = decodeProjectURLBookmark(from: coder) else { return }

		let project = getOrAddProject(for: url)

		associateDocument(document, to: project)
	}

	public override func associateDocument(_ document: NSDocument, to container: ProjectModel) {
		guard let document = document as? BaseDocument else { return }

		container.addDocument(document)
	}

	public override func disassociateDocument(_ document: NSDocument) {
		guard let document = document as? BaseDocument else { return }
		guard let proj = document.project else { return }

		proj.removeDocument(document)

		if proj.documents.isEmpty {
			closeProject(proj)
		}

		updateWindowMenu()
	}

	public override func openUntitledDocumentAndDisplay(_ displayDocument: Bool) throws -> NSDocument {
		return try super.openUntitledDocumentAndDisplay(displayDocument)
	}

	public override func openUntitledDocumentAndDisplay(_ displayDocument: Bool, in container: ProjectModel) throws -> NSDocument {
		let doc = try super.openUntitledDocumentAndDisplay(false, in: container)

		let result = OpenDocumentResult.success((doc, false))

		handleOpen(result: result, display: displayDocument, completionHandler: { _ in })

		return doc
	}

	public func openDocument(withContentsOf url: URL, inOrFind container: ProjectModel?, display: Bool) async throws -> (NSDocument, Bool) {
		let project = container ?? projects.first { url.absoluteString.hasPrefix($0.url.absoluteString) }

		if let project = project {
			return try await openDocument(withContentsOf: url, in: project, display: true)
		}

		return try await openDocument(withContentsOf: url, display: true)
	}
}

extension ProjectDocumentController {
	private func addProject(_ project: ProjectModel) {
		if getProject(for: project.url) == nil {
			projects.insert(project)
		}
	}

	private func getProject(for url: URL) -> ProjectModel? {
		return projects.first(where: { url.path.hasPrefix($0.url.path) })
	}

	private func getOrAddProject(for url: URL) -> ProjectModel {
		if let p = getProject(for: url) {
			return p
		}

		let project = ProjectModel(url: url)

		addProject(project)

		return project
	}

	private func closeProjectIfRequired(_ project: ProjectModel) {
		guard project.documents.count == 0 else {
			return
		}

		projectRemovedHandler(project)

		self.projects.remove(project)

		updateWindowMenu()
	}

	private static let bookmarkDataKey = "com.chimehq.Edit.project-bookmark"

	private func decodeProjectURLBookmark(from state: NSCoder) -> URL? {
		let key = ProjectDocumentController.bookmarkDataKey

		guard let bookmarkData = state.decodeObject(of: [NSData.self], forKey: key) as? Data else {
			return nil
		}

		return URL.resolveFileBookmark(bookmarkData)
	}

}

extension ProjectDocumentController {
	private func closeProject(_ project: ProjectModel) {
		assert(projects.remove(project) != nil)
	}

	private func updateWindowMenu() {
	}

	private func handleNewDocument(_ document: NSDocument) {
		guard let doc = document as? BaseDocument else { return }

		doc.didCompleteOpen()
	}

	private func frontmostWindow(for url: URL) -> NSWindow? {
		guard
			let project = getProject(for: url),
			project.url == url
		else {
			return nil
		}

		return project.frontmostWindow
	}
}
