import AppKit

import ChimeKit
import ContainedDocument

import ProjectWindow

/// Common interface for all documents contained within a Project.
///
/// I've tried to factor this into an inheritance arrangement, but its quite complex because of the relationship between NSDocument and NSDocumentController. It might be possible to do something with NSDocumentController's makeDocument, but I haven't looked into it closely.
protocol ProjectDocument: ContainedDocument<Project>, Hashable {
	@MainActor
	var projectContext: ProjectContext? { get set }

	@MainActor
	var defaultProjectRoot: URL? { get }

	@MainActor
	func willRemoveDocument()
	@MainActor
	func didCompleteOpen()
}

@MainActor
extension ProjectDocument {
	private var documentController: ProjectDocumentController {
		ProjectDocumentController.sharedController
	}

	private var project: Project? {
		documentController.documentContainer(for: self)
	}

	/// Begins the process of opening a URL.
	private func openURL(_ url: URL) {
		Task { [weak self] in
			await self?.openURL(url)
		}
	}

	private func openURL(_ url: URL) async {
		do {
			_ = try await documentController.openDocument(withContentsOf: url, inOrFind: project, display: true)
		} catch {
			Swift.print("failed to open url: ", url, error)
		}
	}

	private var siblingWindowControllers: [ProjectWindowController] {
		guard let docs = project?.documents else { return [] }

		return docs
			.filter { $0 !== self }
			.flatMap { $0.windowControllers }
			.compactMap { $0 as? ProjectWindowController }
	}

	func makeProjectWindowController(contentViewController: NSViewController, context: DocumentContext) -> ProjectWindowController {
		ProjectWindowController(
			contentViewController: contentViewController,
			documentContext: context,
			siblingProvider: { [weak self] in self?.siblingWindowControllers ?? [] },
			onOpen: { [weak self] in self?.openURL($0) }
		)
	}
}
