import Cocoa
import SwiftUI

import DocumentContent
import Neon
import Theme

final class LineNumberViewController: NSViewController {
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
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func loadView() {
		// inject a hidden view into the hierarchy to observe SwiftUI theme changes

		let observingView = Text("")
			.hidden()
			.onThemeChange { [weak self] in self?.updateTheme($0, context: $1) }
			.onDocumentContentChange { [weak self] in self?.representedObject = $0 }
			.onDocumentSelectionChange { [weak self] in self?.selectionChanged($0) }

		let hiddenView = NSHostingView(rootView: observingView)

		regionView.addSubview(hiddenView)

		self.view = regionView
	}

	override var representedObject: Any? {
		didSet {
			precondition(representedObject is DocumentContent)

			rangeValidator.invalidate(.all)
		}
	}
}

extension LineNumberViewController {
	func updateTheme(_ theme: Theme, context: Theme.Context) {
		print("oh really?")
	}

	func selectionChanged(_ ranges: [NSRange]) {
		print("ranges are now: \(ranges)")
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
