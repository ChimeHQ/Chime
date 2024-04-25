import AppKit
import OSLog
import SwiftUI

import Document
import ExtensionHost
import PreferencesWindow
import Theme

@main
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let documentController: ProjectDocumentController
	private lazy var preferencesController: NSWindowController = {
		let window = NSWindow(contentRect: .zero, styleMask: [.closable, .titled], backing: .buffered, defer: true)

		window.contentView = NSHostingView(rootView: SettingsView(themeStore: themeStore))

		return NSWindowController(window: window)
	}()

	private let extensionSystem: ExtensionSystem
	private let themeStore = ThemeStore()

	private var tempWindow: NSWindow?

    override init() {
        UserDefaults.standard.register(defaults: [
            "NSApplicationCrashOnExceptions": true,
        ])

        // NSDocumentController subclass instances must be manually created before any NSDocumentController functionality is used
		self.documentController = ProjectDocumentController(themeStore: themeStore)
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
		preferencesController.window?.center()
		preferencesController.showWindow(self)
    }
}
