import XCTest
@testable import Chime

final class ConfigurationTests: XCTestCase {
	func testCurrentYearAppearsInInfoPlistCopyright() throws {
		let bundle = Bundle(for: AppDelegate.self)
		let plist = try XCTUnwrap(bundle.infoDictionary)

		let string = try XCTUnwrap(plist["NSHumanReadableCopyright"] as? String)

		let formatter = DateFormatter()

		formatter.dateFormat = "yyyy"

		let currentYear = formatter.string(from: Date())

		XCTAssert(string.contains(currentYear))
	}
}
