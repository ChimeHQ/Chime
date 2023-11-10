import Foundation
import UniformTypeIdentifiers

import ChimeKit

public struct DocumentState {
	public internal(set) var context: DocumentContext
	public internal(set) var content: DocumentContent

	init() {
		self.context = DocumentContext()
		self.content = DocumentContent()
	}
}

extension DocumentState: Equatable {
}

extension DocumentState {
	mutating func update(url: URL?) {
		update(url: url, typeName: context.uti.identifier)
	}

	mutating func read(from url: URL, typeName: String) throws {
		// TODO: doc attributes need to be inited from the theme
		self.content = try DocumentContent(url: url, documentAttributes: [:])
		update(url: url, typeName: typeName)
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
									   contentId: content.identity,
									   url: url,
									   uti: uti,
									   configuration: config,
									   projectContext: context.projectContext)
	}
}
