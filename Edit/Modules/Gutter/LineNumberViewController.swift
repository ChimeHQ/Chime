import Cocoa
import SwiftUI

import DocumentContent
import Neon
import Theme

final class LineNumberViewController: NSViewController {
	private var didChangeObserver: NSObjectProtocol?

	private lazy var regionView = RegionLabellingView(
		regionProvider: { [weak self] in self?.labelledRegions(for: $0) ?? [] }
	)

	private lazy var widthCalculator = NumberWidthCalculator(
		attributeProvider: { [weak self] in self?.allPossibleAttributes ?? [] }
	)

	private lazy var rangeValidator = RangeStateValidator(
		configuration: .init(
			lengthProvider: { [weak self] in self?.textLength ?? 0 },
			syncValidateRange: { [weak self] in self?.validateRange($0) ?? .success(.zero) },
			validateRange: { [weak self] in await self?.validateRange($0) ?? .zero }))

	init() {
		super.init(nibName: nil, bundle: nil)

		self.didChangeObserver = NotificationCenter.default.addObserver(
			forName: DocumentContent.didApplyMutationsNotification,
			object: nil,
			queue: nil,
			using: { _ in
				print("did this happen?")
			})
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		// inject a hidden view into the hierarchy to observe SwiftUI changes

		let observingView = Text("")
			.hidden()
			.onThemeChange { [weak self] in self?.updateTheme($0, context: $1) }
			.onDocumentContentChange { [weak self] _ in self?.contentChanged() }
			.onDocumentCursorsChange { [weak self] in self?.cursorsChanged($0) }

		let hiddenView = NSHostingView(rootView: observingView)

		regionView.addSubview(hiddenView)

		self.view = regionView
	}
}

extension LineNumberViewController {
	private func updateTheme(_ theme: Theme, context: Theme.Context) {
		print("theme change?")
	}

	private func cursorsChanged(_ cursors: [Cursor]) {
		print("cursors are now: \(cursors)")
	}

	private func contentChanged() {
		rangeValidator.invalidate(.all)
	}
}

extension LineNumberViewController {
	private func labelledRegions(for region: Region) -> [LabelledRegion] {
		[
			LabelledRegion(label: NSAttributedString("a"), region: .init(position: 0, size: 20)),
			LabelledRegion(label: NSAttributedString("b"), region: .init(position: 20, size: 20)),
			LabelledRegion(label: NSAttributedString("c"), region: .init(position: 40, size: 20)),
		]
	}
}

extension LineNumberViewController {
	private var textLength: Int {
		0
	}

	private func validateRange(_ range: NSRange) -> RangeStateValidator.ValidationResult {
		.asyncRequired
	}

	private func validateRange(_ range: NSRange) async -> NSRange {
		range
	}
}

extension LineNumberViewController {
	private var allPossibleAttributes: [[NSAttributedString.Key: Any]] {
		[[:]]
	}
}
