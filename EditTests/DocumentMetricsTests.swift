import XCTest

@testable import DocumentContent

final class TextMetricsTests: XCTestCase {
	func makeMetrics(with string: String) -> (TextMetrics, TextStorage<Int>) {
		let textStorage = NSTextStorage(string: string)

		let metrics = DocumentMetrics(storage: storageRef)

		return (metrics, storageRef)
	}

	func testLineCountAfterInitialization() {
		let (metrics, _) = makeMetrics(with: "")

		XCTAssertEqual(1, metrics.lineCount())
	}

	func testLineCountWithoutTrailingNewline() {
		let string = "1111\n2222\n3333\n4444"
		let (metrics, _) = makeMetrics(with: string)

		// simulate an insert
		metrics.didApplyMutations([.init(insert: string, at: 0)])

		XCTAssertEqual(4, metrics.lineCount())
	}
}
