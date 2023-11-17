import SwiftUI

@MainActor
@Observable
final class SourceViewStateModel {
	public var selectedRanges: [NSRange] = []
}
