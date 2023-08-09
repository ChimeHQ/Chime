import Foundation

final class NavigatorModel<Value: Hashable> {
	let root: Node
	private let configuration: Configuration

	init(root: Value, configuration: Configuration) {
		self.root = Node(value: root)
		self.configuration = configuration
	}

	func children(for node: Node) -> [Node] {
		node.childern(using: configuration.subValueProvider)
	}

	func nodeHasChildren(_ node: Node) -> Bool {
		configuration.hasSubvalues(node.value)
	}
}

extension NavigatorModel {
	typealias ValueProvider = (Value) -> [Value]
	typealias HasSubvaluesProvider = (Value) -> Bool

	struct Configuration {
		let subValueProvider: ValueProvider
		let hasSubvalues: HasSubvaluesProvider
	}
}

extension NavigatorModel {
	final class Node {
		let value: Value
		var children: [Node]?

		init(value: Value) {
			self.value = value
			self.children = nil
		}

		func childern(using provider: ValueProvider) -> [Node] {
			if let nodes = children {
				return nodes
			}

			let nodes = provider(value).map { Node(value: $0) }

			self.children = nodes

			return nodes
		}
	}
}
