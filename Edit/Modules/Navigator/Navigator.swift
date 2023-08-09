import SwiftUI

import ChimeKit

extension URL {
	var directoryContents: [URL] {
		let keys: [URLResourceKey] = [
			.isDirectoryKey,
			.isHiddenKey
		]

		let children = try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: keys)

		return children ?? []
	}

	var isDirectory: Bool {
		(try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
	}
}

enum NavigatorItem: Hashable {
	case file(URL)

	func children() -> [NavigatorItem] {
		switch self {
		case .file(let url):
			if url.isDirectory == false {
				return []
			}

			return url.directoryContents.map { NavigatorItem.file($0) }
		}
	}

	var hasChildren: Bool {
		switch self {
		case let .file(url):
			return url.isDirectory
		}
	}
}

@Observable
final class FileNavigatorModel {
	typealias InternalModel = NavigatorModel<NavigatorItem>

	private(set) var outlineModel: InternalModel?

	init() {
	}

	func updateContext(_ context: ProjectContext?) {
		guard let context = context else {
			self.outlineModel = nil
			return
		}

		let root = NavigatorItem.file(context.url)

		self.outlineModel = InternalModel(root: root, configuration: navigatorConfiguration)
	}

	private var navigatorConfiguration: InternalModel.Configuration {
		.init(subValueProvider: { $0.children() }, hasSubvalues: { $0.hasChildren })
	}
}

public struct Navigator: View {
	@Environment(\.projectContext) private var context
	@State private var model = FileNavigatorModel()

	public init() {
	}

	@ViewBuilder
	private var content: some View {
		if let outlineModel = model.outlineModel {
			NavigatorView(model: outlineModel)
				.listStyle(.sidebar)
		} else {
			Text("no project")
				.frame(maxWidth: .infinity, maxHeight: .infinity)
		}
	}

	public var body: some View {
		content
			.onChange(of: context) { model.updateContext($1) }
	}
}
