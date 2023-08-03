import SwiftUI

import ChimeKit
import WindowTreatment

public struct Navigator: View {
	@Environment(\.projectContext) private var context
	@Environment(\.windowState) private var windowState

	private let items = ["a", "b", "c"]

	public init() {
	}

	public var body: some View {
		Text("context: \(context?.url.absoluteString ?? "none")")
		List {
			ForEach(items, id: \.self) { item in
				Text(item)
					.onTapGesture {
						print("need to open a thing")
					}
			}
		}
		.listStyle(.sidebar)
		.onChange(of: windowState) { _, _ in print("window state") }
		.onChange(of: context) { _, _ in print("context changed") }
	}
}
