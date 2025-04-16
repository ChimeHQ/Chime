import SwiftUI

import ChimeKit
import Outline

@MainActor
@Observable
public final class FileNavigatorModel {
	private(set) var outlineData: OutlineData<NavigatorItem, String>

	public var expansion = Set<String>()
	public var selection = Set<String>()

	public init() {
		self.outlineData = OutlineData(
			root: .none,
			subValues: {
				try await Task.sleep(for: .seconds(2))
				return $0.children()
			},
			id: \.id,
			hasSubvalues: \.hasChildren
		)
	}

	public var root: NavigatorItem {
		get { outlineData.root }
		set {
			outlineData.root = newValue
		}
	}

	static func configureView(_ view: NSOutlineView) {
		view.setDraggingSourceOperationMask([.move, .copy, .delete], forLocal: false)
		view.setDraggingSourceOperationMask([.move, .copy], forLocal: true)
		view.registerForDraggedTypes([.fileURL])
	}
}

@MainActor
public struct Navigator: View {
	@Environment(FileNavigatorModel.self) private var model
	@Environment(\.projectContext) private var context
	@Environment(\.openURL) private var openURL

	let openTapCount = 1

	public init() {
	}

	public func openItem(_ item: NavigatorItem) {
		switch item {
		case .file(let url):
			openURL(url)
		default:
			fatalError("need to handle this")
		}
	}

	public var body: some View {
		@Bindable var model = model

		NavigatorScrollView {
			OutlineView(
				data: model.outlineData,
				expansion: $model.expansion,
				selection: $model.selection,
				configuration: FileNavigatorModel.configureView
			) { value in
				Text(value.name)
					.onTapGesture(count: openTapCount, perform: { self.openItem(value) })
			}
		}
		.padding()
//			.onChange(of: context) { model.updateContext($1) }
		.onChange(of: model.selection) { print("selection:", $0, $1) }
	}
}
