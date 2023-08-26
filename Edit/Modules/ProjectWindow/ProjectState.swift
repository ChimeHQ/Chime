import Foundation

import ChimeKit
import Navigator

@MainActor
public struct ProjectState {
	public let context: ProjectContext
	public let navigatorModel: FileNavigatorModel

	public init(context: ProjectContext) {
		self.context = context
		self.navigatorModel = FileNavigatorModel()
	}

	public init(url: URL) {
		self.init(context: ProjectContext(url: url))
	}
}
