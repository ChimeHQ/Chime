import Cocoa
import SwiftUI

import DocumentContent
import TextSystem
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

	private let textSystem: TextViewSystem
	private var selectedRanges = [NSRange]()

	init(textSystem: TextViewSystem) {
		self.textSystem = textSystem

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private var layout: TextLayout {
		textSystem.textLayout
	}

	private var storage: TextViewSystem.Storage {
		textSystem.storage
	}

	private var metricsProvider: TextMetrics.ValueProvider {
		textSystem.textMetrics.valueProvider
	}

	override func loadView() {
		// inject a hidden view into the hierarchy to observe SwiftUI changes

		let observingView = Text("")
			.hidden()
			.onThemeChange { [weak self] in self?.updateTheme($0, context: $1) }
//			.onDocumentContentChange { [weak self] in self?.contentChanged($0) }
			.onDocumentCursorsChange { [weak self] in self?.cursorsChanged($0) }
			.onTextMetricsInvalidation { [weak self] in self?.invalidate($0.nsRangeView) }

		let hiddenView = NSHostingView(rootView: observingView)

		regionView.addSubview(hiddenView)

		self.view = regionView
	}

	public override var representedObject: Any? {
		didSet {
			let fullRange = NSRange(0..<storage.currentLength)
			invalidate([fullRange])
		}
	}

	private func invalidate(_ ranges: [NSRange]) {
		guard let location = ranges.map({ $0.location }).min() else { return }

		let startRange = NSRange(location: location, length: 1)

		guard let firstFragment = layout.lineFragmentsInRange(startRange).first else { return }

		let height = regionView.visibleRect.maxY - firstFragment.bounds.minY

		let invalidRect = CGRect(
			x: regionView.bounds.minX,
			y: firstFragment.bounds.minY,
			width: regionView.bounds.width,
			height: height
		)

		print("invaliding: \(invalidRect), \(regionView.visibleRect)")

		updateThickness()

		regionView.setNeedsDisplay(invalidRect)
	}
}

extension LineNumberViewController {
	private func updateTheme(_ theme: Theme, context: Theme.Context) {
		print("theme change?")
	}

	private func cursorsChanged(_ cursors: [Cursor]) {
		let oldRanges = selectedRanges
		self.selectedRanges = cursors.map { $0.selection }

		invalidate(oldRanges + selectedRanges)
	}

	private func contentChanged(_ content: DocumentContent?) {
		self.representedObject = content
	}

	private func updateThickness() {
		widthCalculator.maximumNumber = textSystem.textMetrics.lastLine.index

		regionView.thickness = widthCalculator.requiredWidth
	}
}

extension LineNumberViewController {
	private func isRangeSelected(_ range: NSRange) -> Bool {
		return selectedRanges.contains(where: { (selectedRange) -> Bool in
			if NSIntersectionRange(range, selectedRange).length > 0 {
				return true
			}

			if range.contains(selectedRange.location) {
				return true
			}

			return false
		})
	}

	private func styleForLine(_ line: Line, in range: NSRange, lastLine: Bool) -> [NSAttributedString.Key : Any] {
		var attrs = [
			NSAttributedString.Key.foregroundColor: NSColor.white,
			NSAttributedString.Key.font: NSFont.systemFont(ofSize: 10.0),
			NSAttributedString.Key.paragraphStyle: NSParagraphStyle.rightAligned
		]

		let lastPositionSelected = selectedRanges == [NSRange(location: line.max, length: 0)]
		let cursorAtEndOfText = lastLine && lastPositionSelected
		let selected = isRangeSelected(range)

		if cursorAtEndOfText || selected {
			attrs[.foregroundColor] = NSColor.white
		} else if line.whitespaceOnly {
			attrs[.foregroundColor] = NSColor.lightGray
		}

		return attrs
	}

	private func labelledRegions(for region: Region) -> [LabelledRegion] {
		// Use the visible rect to provide an x and width. The value can still be outside the visible rect.
		let visibleRect = layout.visibleRect()
		let rect = NSRect(
			x: visibleRect.minX,
			y: region.position,
			width: visibleRect.size.width,
			height: region.size
		)

		let fragments = layout.lineFragmentsInRect(rect)

		guard fragments.isEmpty == false else {
			return []
		}

		// this works because regions must be contiguous
		let regionRangeStart = fragments.first!.range.location
		let regionRangeEnd = fragments.last!.range.max
		let regionRange = NSRange(regionRangeStart..<regionRangeEnd)

		guard let textMetrics = metricsProvider.sync(.location(regionRangeEnd, fill: .optional)) else {
			return []
		}

		let lines = textMetrics.lines(for: regionRange)

		guard lines.isEmpty == false else {
			return []
		}

		var labelledRegions = [LabelledRegion]()
		var lineIndex = lines.startIndex

		for fragment in fragments {
			let line = lines[lineIndex]
			let range = fragment.range

			// this may not be correct if we have not loaded the entire document
			let last = textMetrics.lastLine.index == lineIndex

			let style = styleForLine(line, in: range, lastLine: last)
			let firstFragment = range.location == lines[lineIndex].location

			let labelString = firstFragment ? "\(line.index)" : "•"

			let label = NSAttributedString(string: labelString, attributes: style)
			let fragmentRegion = Region(position: fragment.bounds.minY, size: fragment.bounds.height)
			let labelledRegion = LabelledRegion(
				label: label,
				background: line.index % 2 == 0 ? .red : .blue,
				region: fragmentRegion
			)

			labelledRegions.append(labelledRegion)

			// check if we need to advance
			precondition(range.max <= line.range.max)
			if range.max == line.range.max {
				lineIndex = lines.index(after: lineIndex)
			}

			if lineIndex >= lines.endIndex {
				break
			}
		}

		return labelledRegions
	}
}

extension LineNumberViewController {
	private var allPossibleAttributes: [[NSAttributedString.Key: Any]] {
		[[:]]
	}
}
