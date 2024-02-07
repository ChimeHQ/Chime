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

	private let editorScrollView = NSScrollView()
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

		observer.contentBoundsChangedHandler = { [weak self] in self?.contentVisibleRectChanged($0.documentVisibleRect) }
		observer.frameChangedHandler = { [weak self] in self?.contentVisibleRectChanged($0.documentVisibleRect) }
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public override func loadView() {
		editorScrollView.hasVerticalScroller = true
		editorScrollView.hasHorizontalScroller = true
		editorScrollView.drawsBackground = true
		editorScrollView.backgroundColor = .black

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
}
