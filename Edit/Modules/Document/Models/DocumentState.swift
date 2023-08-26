import Foundation
import UniformTypeIdentifiers

import ChimeKit

struct DocumentState {
	var context: DocumentContext

	init() {
		self.context = DocumentContext()
	}
}

extension DocumentState: Hashable {
}
