import AppKit

final class SourcePresentationViewController: NSViewController {
	typealias DimensionsChangedHandler = (NSRect, Double) -> Void

	private let underlayClipView: NSClipView
	private let gutterClipView: NSClipView

	var dimensionsChangedHandler: DimensionsChangedHandler = { _, _ in }
	let scrollView: NSScrollView

	private lazy var gutterHiddenConstraint: NSLayoutConstraint = { [unowned self] in
		let itemView = self.gutterClipView

		let constraint = itemView.trailingAnchor.constraint(equalTo: self.view.leadingAnchor)

		constraint.priority = .defaultHigh

		return constraint
	}()

	init(scrollView: NSScrollView) {
		self.scrollView = scrollView
		self.underlayClipView = NSClipView()
		self.gutterClipView = NSClipView()

		gutterClipView.backgroundColor = .blue

		super.init(nibName: nil, bundle: nil)

		NotificationCenter.default.addObserver(self,
											   selector: #selector(contentBoundsDidChange(_:)),
											   name: NSView.boundsDidChangeNotification,
											   object: scrollView.contentView)

		NotificationCenter.default.addObserver(self,
											   selector: #selector(contentFrameDidChange(_:)),
											   name: NSView.frameDidChangeNotification,
											   object: scrollView)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	@objc private func contentBoundsDidChange(_ notification: Notification) {
		guard let clipView = notification.object as? NSClipView else { return }

		let origin = clipView.bounds.origin

		underlayClipView.scroll(to: origin)

		let leadingOrigin = CGPoint(x: 0.0, y: origin.y)

		gutterClipView.scroll(to: leadingOrigin)

		postContentBoundsChanged()
	}

	@objc private func contentFrameDidChange(_ notification: Notification) {
		// This is also necessary, to account for situations where the scrollview is larger
		// enough that the clipview bounds do not *need* to change for correct behavior,
		// but the visible content is definitely still changing sizes
		postContentBoundsChanged()
	}

	override func viewWillAppear() {
		super.viewWillAppear()

		// set this early
		view.window?.initialFirstResponder = documentView

		installUnderlayViewIfNeeded()
		installGutterViewIfNeeded()

		postContentBoundsChanged()
	}

	private func installUnderlayViewIfNeeded() {
		guard let underlay = underlayView else { return }
		guard let docView = documentView else { return }

		underlay.translatesAutoresizingMaskIntoConstraints = false

		let underlayLeading = underlay.leadingAnchor.constraint(equalTo: gutterClipView.leadingAnchor)

		underlayLeading.priority = .defaultLow

		let underlayContainerLeading = underlay.leadingAnchor.constraint(equalTo: view.leadingAnchor)

		NSLayoutConstraint.activate([
			underlay.topAnchor.constraint(equalTo: docView.topAnchor),
			underlay.bottomAnchor.constraint(equalTo: docView.bottomAnchor),
			underlay.trailingAnchor.constraint(equalTo: docView.trailingAnchor),
			underlayLeading,
			underlayContainerLeading,
		])
	}

	private func installGutterViewIfNeeded() {
		guard let gutterView = gutterView else { return }
		guard let docView = documentView else { return }

		gutterView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			gutterView.topAnchor.constraint(equalTo: docView.topAnchor),
			gutterView.bottomAnchor.constraint(equalTo: docView.bottomAnchor),
			gutterView.leadingAnchor.constraint(equalTo: gutterClipView.leadingAnchor),
			gutterClipView.widthAnchor.constraint(equalTo: gutterView.widthAnchor),
		])
	}

	private func postContentBoundsChanged() {
		dimensionsChangedHandler(contentBounds, gutterWidth)
	}

	var documentView: NSView? {
		get {
			return scrollView.documentView
		}
		set {
			scrollView.documentView = newValue
		}
	}

	var gutterWidth: CGFloat {
		return gutterVisible ? gutterClipView.bounds.width : 0.0
	}

	var contentBounds: NSRect {
		return scrollView.contentView.bounds
	}

	public var underlayView: NSView? {
		get {
			return underlayClipView.documentView
		}
		set {
			underlayClipView.documentView = newValue

			installUnderlayViewIfNeeded()
		}
	}

	public var gutterView: NSView? {
		get {
			return gutterClipView.documentView
		}
		set {
			gutterClipView.documentView = newValue

			installGutterViewIfNeeded()
		}
	}

	public var overlayView: NSView? {
		didSet {
			oldValue?.removeFromSuperview()

			guard let overlayView = overlayView else { return }
			guard let docView = documentView else { return }

			precondition(overlayView.superview == nil)

			docView.addSubview(overlayView)
			overlayView.translatesAutoresizingMaskIntoConstraints = false

			NSLayoutConstraint.activate([
				overlayView.topAnchor.constraint(equalTo: docView.topAnchor),
				overlayView.bottomAnchor.constraint(equalTo: docView.bottomAnchor),
				overlayView.leadingAnchor.constraint(equalTo: docView.leadingAnchor),
				overlayView.trailingAnchor.constraint(equalTo: docView.trailingAnchor),
			])
		}
	}

	public var underlayDocumentRect: NSRect {
		return underlayClipView.documentRect
	}

	override func loadView() {
		scrollView.drawsBackground = false

		gutterClipView.drawsBackground = false
		underlayClipView.drawsBackground = false

		let container = NSView()

		container.subviews = [underlayClipView, gutterClipView, scrollView]
		for subview in container.subviews {
			subview.translatesAutoresizingMaskIntoConstraints = false
		}

		self.view = container

		let gutterLeadingConstraint = gutterClipView.leadingAnchor.constraint(equalTo: view.leadingAnchor)

		gutterLeadingConstraint.priority = NSLayoutConstraint.Priority.windowSizeStayPut

		NSLayoutConstraint.activate([
			underlayClipView.topAnchor.constraint(equalTo: view.topAnchor),
			underlayClipView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			underlayClipView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			underlayClipView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

			gutterClipView.topAnchor.constraint(equalTo: view.topAnchor),
			gutterClipView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			gutterLeadingConstraint,

			scrollView.topAnchor.constraint(equalTo: view.topAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: gutterClipView.trailingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])
	}
}

extension SourcePresentationViewController {
	var gutterVisible: Bool {
		get {
			return gutterHiddenConstraint.isActive == false
		}
		set {
			precondition(gutterClipView.isDescendant(of: view))

			gutterHiddenConstraint.isActive = newValue == false
		}
	}

	@IBAction func toggleGutter(_ sender: Any?) {
		view.layoutSubtreeIfNeeded()

		NSAnimationContext.runAnimationGroup { (context) in
			context.allowsImplicitAnimation = true
			context.completionHandler = {
				self.postContentBoundsChanged()
			}

			self.gutterVisible.toggle()

			self.view.layoutSubtreeIfNeeded()
		}
	}
}

extension SourcePresentationViewController: NSMenuItemValidation {
	func validateMenuItem(_ item: NSMenuItem) -> Bool {
		switch item.action {
		case #selector(toggleGutter(_:))?:
			if gutterVisible {
				item.title = NSLocalizedString("menu.hide-gutter", comment: "Hide Gutter")
			} else {
				item.title = NSLocalizedString("menu.show-gutter", comment: "Show Gutter")
			}
		default:
			break
		}

		return true
	}
}
