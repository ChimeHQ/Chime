import AppKit
import Combine

import ViewPlus

/// Keeps two independent scroll views synchronized.
public final class SynchronizedScrollViewController: NSViewController {
    private let primaryScrollView: NSScrollView
    private let secondaryScrollView: NSScrollView
    private var heightConstraint: NSLayoutConstraint?
    private var subscriptions = Set<AnyCancellable>()
    private var height: CGFloat = 0.0 {
        didSet { heightUpdated(oldValue) }
    }

    public init(view: NSScrollView, synchronizeWith primaryScrollView: NSScrollView) {
        self.primaryScrollView = primaryScrollView
        self.secondaryScrollView = view

        super.init(nibName: nil, bundle: nil)

        self.view = view

        NotificationCenter.default.publisher(for: NSView.boundsDidChangeNotification, object: primaryScrollView.contentView)
            .sink { [weak self] _ in
                self?.synchronizePositions()
            }
            .store(in: &subscriptions)

        NotificationCenter.default.publisher(for: NSView.frameDidChangeNotification, object: primaryScrollView)
            .sink { [weak self] _ in
                if let primaryDocumentView = primaryScrollView.documentView {
                    self?.height = primaryDocumentView.bounds.height
                }

                self?.synchronizePositions()
            }
            .store(in: &subscriptions)

    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func heightUpdated(_ oldValue: CGFloat) {
        if oldValue == height {
            return
        }

        heightConstraint?.constant = height

        // without this, the scroll position can get out of sync when the height changes
        view.layoutSubtreeIfNeeded()
    }

    public var documentView: NSView? {
        get { secondaryScrollView.documentView }
        set {
            secondaryScrollView.documentView = newValue

            guard let docView = newValue else { return }

            docView.useAutoLayout = true
            let contentView = secondaryScrollView.contentView

            let constraint = docView.heightAnchor.constraint(equalToConstant: height)
            self.heightConstraint = constraint

            NSLayoutConstraint.activate([
                docView.topAnchor.constraint(equalTo: contentView.topAnchor),
                docView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                docView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

                constraint,
            ])

            synchronizePositions()
        }
    }

    private func synchronizePositions() {
        let clipView = primaryScrollView.contentView

        let offset = -clipView.bounds.origin.y

        let constrainedPoint = NSPoint(x: 0.0, y: offset)

        secondaryScrollView.contentView.scroll(to: constrainedPoint)
        secondaryScrollView.reflectScrolledClipView(secondaryScrollView.contentView)
    }
}
