import AppKit

import ContainedDocument

public final class ProjectDocumentController: ContainedDocumentController<ProjectModel> {
	private(set) var projects = Set<ProjectModel>()

	public override func associateDocument(_ document: NSDocument, to container: ProjectModel) {
		guard let document = document as? TextDocument else { return }

		container.addDocument(document)
	}

	public override func disassociateDocument(_ document: NSDocument) {
		guard let document = document as? TextDocument else { return }
		guard let proj = document.project else { return }

		proj.removeDocument(document)

		if proj.documents.isEmpty {
			closeProject(proj)
		}

		updateWindowMenu()
	}
}

extension ProjectDocumentController {
	private func closeProject(_ project: ProjectModel) {
		assert(projects.remove(project) != nil)
	}

	private func updateWindowMenu() {
	}
}
