import Foundation
import UniformTypeIdentifiers

import ChimeKit
import DocumentContent

@MainActor
public struct DocumentState {
	public internal(set) var context: DocumentContext
	public private(set) var contentId: DocumentContentIdentity

	init(contentId: DocumentContentIdentity) {
		self.context = DocumentContext()
		self.contentId = contentId
	}
}

extension DocumentState {
	public static func == (lhs: DocumentState, rhs: DocumentState) -> Bool {
		lhs.context == rhs.context && lhs.contentId == rhs.contentId
	}
}

extension DocumentState {
	mutating func updateProjectContext(_ projectContext: ProjectContext?) {
		self.context = DocumentContext(id: context.id,
									   contentId: contentId,
									   url: context.url,
									   uti: context.uti,
									   configuration: context.configuration,
									   projectContext: projectContext)
	}

	mutating func update(url: URL?) {
		update(url: url, typeName: context.uti.identifier)
	}

	mutating func update(url: URL?, typeName: String, contentId: DocumentContentIdentity) {
		self.contentId = contentId
		self.update(url: url, typeName: typeName)
	}

	mutating func update(url: URL?, typeName: String) {
		let uti: UTType

		if let url = url {
			uti = (try? url.resolvedContentType) ?? .plainText
		} else {
			uti = context.uti
		}

		// TODO: more work needed here
		let config = context.configuration

		self.context = DocumentContext(id: context.id,
									   contentId: contentId,
									   url: url,
									   uti: uti,
									   configuration: config,
									   projectContext: context.projectContext)
	}
}
