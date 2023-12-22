import Cocoa
import Quartz

import ChimeKit
import Editor
import TextSystem
import Theme

final class PreviewViewController: NSViewController, QLPreviewingController {
	private let sourceViewController = SourceViewController()
	private let editorContentController: EditorContentViewController
	private let textSystem: TextViewSystem

	override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
		self.textSystem = TextViewSystem(textView: sourceViewController.textView)
		self.editorContentController = EditorContentViewController(textSystem: textSystem, sourceViewController: sourceViewController)

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		self.view = editorContentController.view
    }

	func preparePreviewOfFile(at url: URL) async throws {
		let config = DocumentConfiguration()
		let theme = Theme()
		let context = Theme.Context(window: self.view.window)
		let attrs = theme.typingAttributes(tabWidth: config.tabWidth, context: context)

		try textSystem.reload(from: url, attributes: attrs)
	}
}
