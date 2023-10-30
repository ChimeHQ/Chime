import Foundation
import UniformTypeIdentifiers

import ChimeKit

public struct DocumentState {
	public internal(set) var context: DocumentContext

	init() {
		self.context = DocumentContext()
	}
}

extension DocumentState: Hashable {
}

extension DocumentState {
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
									   contentId: context.contentId,
									   url: url,
									   uti: uti,
									   configuration: config,
									   projectContext: context.projectContext)
	}
}
