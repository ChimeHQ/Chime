import Cocoa
import SwiftUI

import Borderline
import DocumentContent
import TextSystem
import Neon
import Theme
import ThemePark

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
	private var normalLineAttributes: [NSAttributedString.Key: Any] = [:]
	private var selectedLineAttributes: [NSAttributedString.Key: Any] = [:]
	private var emptyLineAttributes: [NSAttributedString.Key: Any] = [:]
	private var labellingAttemptFailed = false

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

	private var metricsProvider: TextMetricsCalculator.ValueProvider {
		textSystem.textMetricsCalculator.valueProvider
	}

	override func loadView() {
		// inject a hidden view into the hierarchy to observe SwiftUI changes

		let observingView = Text("")
			.hidden()
			.onThemeChange { [weak self] in self?.updateTheme($0, context: $1) }
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

	private func computeInvalidationRect(for ranges: [NSRange]) -> CGRect? {
		guard let location = ranges.map({ $0.location }).min() else { return nil }
		
		let startRange = NSRange(location: location, length: 1)

		guard let firstFragment = layout.lineFragmentsInRange(startRange).first else { return nil }

		let height = regionView.visibleRect.maxY - firstFragment.bounds.minY

		return CGRect(
			x: regionView.bounds.minX,
			y: firstFragment.bounds.minY,
			width: regionView.bounds.width,
			height: height
		)
	}
	
	private func invalidate(_ ranges: [NSRange]) {
		let rect: CGRect
		
		// if a previous attempt as failed, we cannot know if the invalidated ranges will cover the region we need to redraw
		if labellingAttemptFailed {
			rect = layout.visibleRect()
		} else {
			rect = computeInvalidationRect(for: ranges) ?? layout.visibleRect()
		}

		updateThickness()

		invalidate(rect)
	}
}

extension LineNumberViewController {
	private func updateTheme(_ theme: Theme, context: Query.Context) {
		let baseStyle = theme.style(for: .gutter(.label), context: context)
		let baseColor = baseStyle.color
		let baseFont = baseStyle.font ?? Theme.fallbackFont

		normalLineAttributes = [
			NSAttributedString.Key.foregroundColor: baseColor.emphasize(by: -0.5),
			NSAttributedString.Key.font: baseFont,
			NSAttributedString.Key.paragraphStyle: NSParagraphStyle.rightAligned
		]

		selectedLineAttributes = [
			.foregroundColor: baseColor,
			.font: baseFont,
			.paragraphStyle: NSParagraphStyle.rightAligned
		]

		emptyLineAttributes = [
			.foregroundColor: baseColor.emphasize(by: -0.75),
			.font: baseFont,
			.paragraphStyle: NSParagraphStyle.rightAligned
		]

		let fullRange = NSRange(0..<storage.currentLength)
		invalidate([fullRange])
	}

	private func cursorsChanged(_ cursors: CursorSet) {
		let oldRanges = selectedRanges
		self.selectedRanges = cursors.ranges

		invalidate(oldRanges + selectedRanges)
	}

	private func updateThickness() {
		let metrics = metricsProvider.sync(.processed)
			
		widthCalculator.maximumNumber = metrics?.lastLine.index ?? 0

		let padding = 6.0
		
		regionView.thickness = widthCalculator.requiredWidth + padding
	}

	func invalidate(_ invalidRect: CGRect) {
		regionView.setNeedsDisplay(invalidRect)
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
			
			if range.location == selectedRange.location {
				return true
			}

			return false
		})
	}

	private func styleForLine(_ line: Line<Int>, in range: NSRange, lastLine: Bool) -> [NSAttributedString.Key : Any] {
		let lastPositionSelected = selectedRanges == [NSRange(location: line.upperBound, length: 0)]
		let cursorAtEndOfText = lastLine && lastPositionSelected

		if cursorAtEndOfText {
			return selectedLineAttributes
		}

		if isRangeSelected(range) {
			return selectedLineAttributes
		}

		if line.isWhitespaceOnly {
			return emptyLineAttributes
		}

		return normalLineAttributes
	}

	private func backgroundForLine(_ line: Line<Int>) -> NSColor {
//		line.index % 2 == 0 ? .red : .blue
		.clear
	}

	private func labelledRegions(for region: Region) -> [LabelledRegion] {
		// Use the visible rect to provide an x and width. The region could still be outside the visible rect.
		let visibleRect = layout.visibleRect()
		let rect = NSRect(
			x: visibleRect.minX,
			y: region.position,
			width: visibleRect.size.width,
			height: region.size
		)

		let fragments = layout.lineFragmentsInRect(rect)

		guard fragments.isEmpty == false else {
			print("no fragments")
			self.labellingAttemptFailed = true
			return []
		}

		// this works because regions must be contiguous
		let regionRangeStart = fragments.first!.range.location
		let regionRangeEnd = fragments.last!.range.max
		let regionRange = NSRange(regionRangeStart..<regionRangeEnd)

		guard let textMetrics = metricsProvider.sync(.location(regionRangeEnd, fill: .optional)) else {
			print("no metrics")
			self.labellingAttemptFailed = true
			return []
		}

		let lines = textMetrics.lines(for: regionRange)

		guard lines.isEmpty == false else {
			print("no lines")
			self.labellingAttemptFailed = true
			return []
		}

		var labelledRegions = [LabelledRegion]()
		var lineIndex = lines.startIndex
		
		self.labellingAttemptFailed = false

		for fragment in fragments {
			let line = lines[lineIndex]
			let range = fragment.range

			// this may not be correct if we have not loaded the entire document
			let last = textMetrics.lastLine.index == lineIndex

			let style = styleForLine(line, in: range, lastLine: last)
			let background = backgroundForLine(line)
			let firstFragment = range.lowerBound == lines[lineIndex].lowerBound

			let number = line.index + 1
			let labelString = firstFragment ? "\(number)" : "•"

			let label = NSAttributedString(string: labelString, attributes: style)
			let fragmentRegion = Region(position: fragment.bounds.minY, size: fragment.bounds.height)
			let labelledRegion = LabelledRegion(
				label: label,
				background: background,
				region: fragmentRegion
			)

			labelledRegions.append(labelledRegion)

			// check if we need to advance
			if range.max >= line.upperBound {
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
