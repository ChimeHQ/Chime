import AppKit
import SwiftUI

import DocumentContent
import Gutter
import ScrollViewPlus
import TextSystem
import Theme
import UIUtility

/// Defines the overall editor scene.
///
/// This controller establishes the larger editor scene, typing together the sub components.
public final class EditorContentViewController: NSViewController {
	public typealias ShouldChangeTextHandler = (NSRange, String?) -> Bool

	private let editorScrollView = EditorScrollView()
	let sourceViewController: SourceViewController
	let editorState: EditorStateModel
	let textSystem: TextViewSystem
	public var contentVisibleRectChanged: (NSRect) -> Void = { _ in }
	private lazy var observer = ScrollViewVisibleRectObserver(scrollView: editorScrollView)

	public init(textSystem: TextViewSystem, sourceViewController: SourceViewController) {
		self.editorState = EditorStateModel()
		self.sourceViewController = sourceViewController
		self.textSystem = textSystem

		super.init(nibName: nil, bundle: nil)

		addChild(sourceViewController)

		// these all have to be weak, because even though we own the scroll view, it gets injected into the view heirarchy, and can outlive this object.

		observer.contentBoundsChangedHandler = { [weak self] in self?.handleVisibleRectChanged($0.documentVisibleRect) }
		observer.frameChangedHandler = { [weak self] in self?.handleVisibleRectChanged($0.documentVisibleRect) }

		editorScrollView.scrollerThicknessChangedHandler = { [weak self] in
			self?.handleLayoutChanged()
		}
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func loadView() {
		editorScrollView.drawsBackground = true
		editorScrollView.backgroundColor = .black
		editorScrollView.hasVerticalScroller = true
		editorScrollView.hasHorizontalScroller = true
		editorScrollView.verticalScroller = ObservableScroller()
		editorScrollView.horizontalScroller = ObservableScroller()

		// allow the scroll view to use the entire height of a full-content windows
		editorScrollView.automaticallyAdjustsContentInsets = false

		let presentationController = SourcePresentationViewController(scrollView: editorScrollView)

		presentationController.gutterView = NSHostingView(rootView: Gutter(textSystem: textSystem))
//		presentationController.underlayView = NSHostingView(rootView: Color.red)
//		presentationController.overlayView = NSHostingView(rootView: Color.blue)
		presentationController.documentView = sourceViewController.view

		// For debugging. Just be careful, because the SourceView/ScrollView relationship is extremely complex.
//		presentationController.documentView = NSHostingView(rootView: BoundingBorders())
//		presentationController.documentView?.translatesAutoresizingMaskIntoConstraints = false

		let hostedView = EditorContent {
			RepresentableViewController({ presentationController })
		}
			.environment(editorState)
			.environment(\.textViewSystem, textSystem)

		self.view = NSHostingView(rootView: hostedView)
	}

	public var selectedRanges: [NSRange] {
		get { editorState.selectedRanges }
		set { editorState.selectedRanges = newValue }
	}

	private func handleVisibleRectChanged(_ rect: CGRect) {
		contentVisibleRectChanged(rect)
		editorState.visibleFrame = rect
	}

	private func handleLayoutChanged() {
		let margins = EdgeInsets(
			top: 0.0,
			leading: 0.0,
			bottom: editorScrollView.horizontalMargin,
			trailing: editorScrollView.verticalMargin
		)

		editorState.contentInsets = margins
	}

	@IBAction
	func toggleStatusBarVisibility(_ sender: Any?) {
		editorState.statusBarVisible.toggle()
	}
}
