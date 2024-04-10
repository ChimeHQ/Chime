import SwiftUI

import TextSystem

struct LineNumberView: NSViewControllerRepresentable {
	@Environment(\.editorVisibleRect) private var editorVisibleRect

	let textSystem: TextViewSystem

	public init(textSystem: TextViewSystem) {
		self.textSystem = textSystem
	}

	public func makeNSViewController(context: Context) -> LineNumberViewController {
		LineNumberViewController(textSystem: textSystem)
	}

	public func updateNSViewController(_ nsViewController: LineNumberViewController, context: Context) {
		nsViewController.invalidate(editorVisibleRect)
	}
}
