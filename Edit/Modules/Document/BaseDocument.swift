import AppKit
import SwiftUI

import ContainedDocument
import Editor
import ProjectWindow

public class BaseDocument: ContainedDocument<ProjectModel> {
	public internal(set) weak var project: ProjectModel?
}

extension BaseDocument {
	func willRemoveDocument() {
	}

	func didCompleteOpen() {
	}
}
