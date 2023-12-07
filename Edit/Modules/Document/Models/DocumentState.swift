import Foundation
import UniformTypeIdentifiers

import ChimeKit
import DocumentContent

public struct DocumentState {
	public internal(set) var context: DocumentContext
	public internal(set) var content: DocumentContent

	private let temporaryID = UUID()

	init() {
		self.context = DocumentContext()
		self.content = DocumentContent(storage: .null)
	}
}

extension DocumentState: Equatable {
}

extension DocumentState {
	mutating func updateProjectContext(_ projectContext: ProjectContext?) {
		self.context = DocumentContext(id: context.id,
									   contentId: temporaryID,
									   url: context.url,
									   uti: context.uti,
									   configuration: context.configuration,
									   projectContext: projectContext)
	}

	mutating func update(url: URL?) {
		update(url: url, typeName: context.uti.identifier)
	}
	
	mutating func update(url: URL?, typeName: String) {
		let uti: UTType

		if let url = url {
			uti = UTType.resolveType(with: typeName, url: url) ?? .plainText
		} else {
			uti = context.uti
		}

		// TODO: more work needed here
		let config = context.configuration

		self.context = DocumentContext(id: context.id,
									   contentId: temporaryID,
									   url: url,
									   uti: uti,
									   configuration: config,
									   projectContext: context.projectContext)
	}
}
