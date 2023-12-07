import AppKit

import TextStory

public final class GutterViewController: NSViewController {
	let lineNumberingController = LineNumberViewController()

	public init() {
		super.init(nibName: nil, bundle: nil)

		addChild(lineNumberingController)
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override public func loadView() {
		self.view = NSView()
		let lineNumberingView = lineNumberingController.view

		view.subviews = [lineNumberingView]
		lineNumberingView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			lineNumberingView.topAnchor.constraint(equalTo: view.topAnchor),
			lineNumberingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			lineNumberingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			lineNumberingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])
	}
}

extension GutterViewController: TextStoringMonitor {
	public nonisolated func willApplyMutation(_ mutation: TextStory.TextMutation, to storage: TextStory.TextStoring) {
	}
	
	public nonisolated func didApplyMutation(_ mutation: TextStory.TextMutation, to storage: TextStory.TextStoring) {
	}
	
	public nonisolated func willCompleteChangeProcessing(of mutation: TextStory.TextMutation?, in storage: TextStory.TextStoring) {
	}
	
	public nonisolated func didCompleteChangeProcessing(of mutation: TextStory.TextMutation?, in storage: TextStory.TextStoring) {
	}
}
