import AppKit

import Document

@main
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
	private let documentController: ProjectDocumentController

	override init() {
		// NSDocumentController subclass instances must be manually created before any NSDocumentController functionality is used
		self.documentController = ProjectDocumentController()

	}

	func applicationDidFinishLaunching(_ aNotification: Notification) {
	}

	func applicationWillTerminate(_ aNotification: Notification) {
	}

	func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
		return true
	}
}
