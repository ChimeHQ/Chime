import AppKit
import OSLog

import ChimeKit
import Document
import PreferencesWindow
import ServiceConnection
import ExtensionHost

@main
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let documentController: ProjectDocumentController
    private let extensionManager: ExtensionManager
    private let appHost: AppHost
    private lazy var preferencesController = PreferencesWindowController()
	private let eventRouter: ApplicationServiceEventRouter

    override init() {
        UserDefaults.standard.register(defaults: [
            "NSApplicationCrashOnExceptions": true,
        ])

        // NSDocumentController subclass instances must be manually created before any NSDocumentController functionality is used
        self.documentController = ProjectDocumentController()

        let appHostConfig = AppHost.Configuration(
            contentProvider: { _ in throw ServiceProviderError.unsupported },
            combinedContentProvider: { _, _ in throw ServiceProviderError.unsupported }
        )

        self.appHost = AppHost(config: appHostConfig)
        self.extensionManager = ExtensionManager(host: appHost)
		self.eventRouter = ApplicationServiceEventRouter(documentController: documentController,
														 extensionInterface: extensionManager.extensionInterface)

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
