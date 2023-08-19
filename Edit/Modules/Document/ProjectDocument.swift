import AppKit

import ChimeKit
import ContainedDocument

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

extension ProjectDocument {
	@MainActor
	func openURL(_ url: URL) async {
		let controller = ProjectDocumentController.sharedController

		let project = controller.documentContainer(for: self)

		do {
			_ = try await controller.openDocument(withContentsOf: url, inOrFind: project, display: true)
		} catch {
			Swift.print("failed to open url: ", url, error)
		}
	}
}
