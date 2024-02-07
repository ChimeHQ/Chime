import AppKit
import OSLog

import Document
import ExtensionHost
import PreferencesWindow

@main
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let documentController: ProjectDocumentController
    private lazy var preferencesController = PreferencesWindowController()
	private let extensionSystem: ExtensionSystem

    override init() {
        UserDefaults.standard.register(defaults: [
            "NSApplicationCrashOnExceptions": true,
        ])

        // NSDocumentController subclass instances must be manually created before any NSDocumentController functionality is used
        self.documentController = ProjectDocumentController()
		self.extensionSystem = ExtensionSystem(documentController: documentController)

		super.init()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

extension AppDelegate {
    @IBAction func showPreferences(_ sender: Any?) {
        preferencesController.showWindow(self)
    }
}
