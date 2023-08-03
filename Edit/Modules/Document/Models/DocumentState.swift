import Foundation
import UniformTypeIdentifiers

import ChimeKit

struct DocumentState {
	let context: DocumentContext

	init() {
		self.context = DocumentContext()
	}
}

extension DocumentState: Hashable {
}
