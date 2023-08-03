import AppKit

final class OpenPanelAccessoryViewController: NSViewController {
	private let hiddenFilesButton: NSButton
	weak var openPanel: NSOpenPanel?
	private var kvoObservation: NSKeyValueObservation?

	init() {
		hiddenFilesButton = NSButton()

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		self.view = NSView()

		hiddenFilesButton.title = "Show Hidden Files"
		hiddenFilesButton.setButtonType(.switch)
		hiddenFilesButton.target = self
		hiddenFilesButton.action = #selector(toggleShowHiddenFiles(_:))

		view.subviews = [hiddenFilesButton]
		hiddenFilesButton.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			view.widthAnchor.constraint(greaterThanOrEqualToConstant: 200.0),
			view.heightAnchor.constraint(greaterThanOrEqualToConstant: 64.0),

			hiddenFilesButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			hiddenFilesButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
		])
	}

	@objc func toggleShowHiddenFiles(_ sender: Any?) {
		if let panel = openPanel {
			panel.showsHiddenFiles = !panel.showsHiddenFiles
		}
	}

	override func viewWillAppear() {
		guard let panel = openPanel else {
			kvoObservation = nil
			return
		}

		hiddenFilesButton.state = panel.showsHiddenFiles ? .on : .off

		kvoObservation = panel.observe(\.showsHiddenFiles, changeHandler: { [unowned self] (obj, _) in
			MainActor.assumeIsolated {
				self.hiddenFilesButton.state = obj.showsHiddenFiles ? .on : .off
			}
		})
	}

	override func viewWillDisappear() {
		kvoObservation = nil
	}
}

