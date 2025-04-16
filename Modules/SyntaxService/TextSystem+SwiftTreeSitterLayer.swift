import Foundation

import DocumentContent
import SwiftTreeSitter
import SwiftTreeSitterLayer

extension TextStorage {
	func layerContent(for limit: Int) -> LanguageLayer.Content {
		let fullString = string
		let read = Parser.readFunction(for: fullString, limit: limit)

		return LanguageLayer.Content(
			readHandler: read,
			textProvider: fullString.predicateTextProvider
		)
	}
	
	func layerContentSnapshot(for limit: Int) -> LanguageLayer.ContentSnapshot {
		let fullString = string
		let read = Parser.readFunction(for: fullString, limit: limit)

		return LanguageLayer.ContentSnapshot(
			readHandler: read,
			textProvider: fullString.predicateTextSnapshotProvider
		)
	}
}

extension TextMetricsCalculator {
	func locationTransformer(_ location: Int) -> Point? {
		guard let metrics = valueProvider.sync(.location(location, fill: .optional)) else {
			return nil
		}

		guard let line = metrics.line(for: location) else {
			return nil
		}

		let column = location - line.lowerBound
		precondition(column >= 0)

		return Point(row: line.index, column: column)
	}
}
