import SwiftUI

public struct SearchItem: View {
	public let count: Int?

	public init(count: Int?) {
		self.count = count
	}

	private var text: String {
		guard let count = count else { return "-" }

		return String(count)
	}

	public var body: some View {
		HStack(spacing: 1.0) {
			StatusItem(style: .leading) {
				Image(systemName: "magnifyingglass")
			}
			StatusItem(style: .trailing) {
				Text(text)
			}
		}
	}
}


#Preview {
	SearchItem(count: nil)
}
