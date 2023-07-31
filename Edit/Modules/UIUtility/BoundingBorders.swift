import SwiftUI

public struct BoundingBorders: View {
	let thickness = 4.0

	public init() {
	}

	public var body: some View {
		VStack(spacing: 1) {
			Rectangle()
				.foregroundStyle(.blue)
				.frame(height: thickness)
			HStack(spacing: 1) {
				Rectangle()
					.foregroundStyle(.green)
					.frame(width: thickness)
				Color.orange
				Rectangle()
					.foregroundStyle(.purple)
					.frame(width: thickness)
			}
			Rectangle()
				.foregroundStyle(.red)
				.frame(height: thickness)
		}
	}
}
