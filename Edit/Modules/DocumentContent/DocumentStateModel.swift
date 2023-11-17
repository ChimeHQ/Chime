import SwiftUI

@MainActor
@Observable
public final class DocumentStateModel {
	public var selectedRanges: [NSRange] = []
	public var documentContent: DocumentContent

	public init(content: DocumentContent) {
		self.documentContent = content
	}
}
