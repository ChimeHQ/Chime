import SwiftUI

import ChimeKit
import WindowTreatment

extension URL {
	var directoryContents: [URL] {
		let children = try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: [.isDirectoryKey])

		return children ?? []
	}
}

/// The model to be displayed
struct Node<Value: Hashable>: Hashable {
	let value: Value
	var children: [Node]? = nil
}

/// The state of the view
struct NavigatorState {
	var expandedSet: Set<IndexPath>
	var selectedSet: Set<IndexPath>
}

public struct Navigator: View {
	@Environment(\.projectContext) private var context
	@Environment(\.windowState) private var windowState

	private let root = Node<String>(value: "a", children: [Node(value: "b"), Node(value: "c")])

	public init() {
	}

	public var body: some View {
		Text("context: \(context?.url.absoluteString ?? "none")")
		List {
			OutlineGroup(root, id: \.value, children: \.children) { item in
				Text(item.value)
			}
		}
		.listStyle(.sidebar)
		.onChange(of: windowState) { _, _ in print("window state") }
		.onChange(of: context) { _, _ in print("context changed") }
	}
}
