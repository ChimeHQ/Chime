import AppKit
import SwiftUI

import ExtensionKit
import ViewPlus

public final class PreferencesWindowController: NSWindowController {
    private let toolbar = NSToolbar(identifier: NSToolbar.Identifier.preferences)

//    lazy var generalPrefsViewController = GeneralPreferencesViewController()
//    lazy var appearancePrefsViewController = AppearancePrefsViewController()
//    lazy var editingBehaviorPrefsViewController = EditingBehaviorPrefsViewController()
    lazy var extensionPrefsViewController = EXAppExtensionBrowserViewController()
//    lazy var commandLinePrefsViewController = NSHostingController(rootView: CommandLinePrefsView())

    public init() {
        let height: CGFloat = 406

        let rect = NSRect(x: 0, y: 0, width: height * 16.0/9.0, height: height)
        let w = NSWindow(contentRect: rect, styleMask: [.closable, .titled], backing: .buffered, defer: true)
        w.center()

        super.init(window: w)

        self.setupContent()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupContent() {
        toolbar.delegate = self
        toolbar.allowsExtensionItems = false
        toolbar.allowsUserCustomization = false
        toolbar.displayMode = .iconAndLabel

        window?.toolbar = toolbar
        window?.showsToolbarButton = false

//        toolbar.selectedItemIdentifier = NSToolbarItem.Identifier.general
//        setActiveController(generalPrefsViewController)
        toolbar.selectedItemIdentifier = .extensions
        setActiveController(extensionPrefsViewController)

        guard let contentView = window?.contentView else {
            return
        }

        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 406),
            contentView.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 16.0/9.0),
        ])
    }

    func setActiveController(_ controller: NSViewController) {
        guard let contentView = window?.contentView else {
            return
        }

        for subview in contentView.subviews {
            subview.isHidden = true
        }

        if controller.view.superview != window?.contentView {
            controller.view.removeFromSuperview()
            contentView.addSubview(controller.view)
            controller.view.useAutoLayout = true

            NSLayoutConstraint.activate([
                controller.view.topAnchor.constraint(equalTo: contentView.topAnchor),
                controller.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                controller.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                controller.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            ])
        }

        controller.view.isHidden = false
    }
}

extension PreferencesWindowController {
    @IBAction func showGeneral(_ sender: Any?) {
//        setActiveController(generalPrefsViewController)
    }

    @IBAction func showAppearance(_ sender: Any?) {
//        setActiveController(appearancePrefsViewController)
    }

    @IBAction func showEditingBehavior(_ sender: Any?) {
//        setActiveController(editingBehaviorPrefsViewController)
    }

    @IBAction func showExtensions(_ sender: Any?) {
        setActiveController(extensionPrefsViewController)
    }

    @IBAction func showCommandLine(_ sender: Any?) {
//        setActiveController(commandLinePrefsViewController)
    }
}

fileprivate extension NSToolbar.Identifier {
    static let preferences = NSToolbar.Identifier("com.chimehq.Edit.Preferences-Toolbar")
}

fileprivate extension NSToolbarItem.Identifier {
    static let general = NSToolbarItem.Identifier("com.chimehq.Edit.Preferences-Toolbar.General")
    static let appearance = NSToolbarItem.Identifier("com.chimehq.Edit.Preferences-Toolbar.Appearance")
    static let editingBehavior = NSToolbarItem.Identifier("com.chimehq.Edit.Preferences-Toolbar.Editing-Behavior")
    static let extensions = NSToolbarItem.Identifier("com.chimehq.Edit.Preferences-Toolbar.Extensions")
    static let commandLine = NSToolbarItem.Identifier("com.chimehq.Edit.Preferences-Toolbar.CommandLine")
}

extension PreferencesWindowController: NSToolbarDelegate {

    public func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        var toolbarItem: NSToolbarItem?

        switch itemIdentifier {
        case .general:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = NSLocalizedString("preferences.toolbar.general", comment: "Preferences Toolbar General Button Label")
            item.paletteLabel = item.label
            item.toolTip = item.label
            item.target = self
            item.action = #selector(showGeneral(_:))
            item.image = NSImage(named: "preferences.toolbar.general")

            toolbarItem = item
        case .appearance:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = NSLocalizedString("preferences.toolbar.appearance", comment: "Preferences Toolbar Appearance Button Label")
            item.paletteLabel = item.label
            item.toolTip = item.label
            item.target = self
            item.action = #selector(showAppearance(_:))
            item.image = NSImage(named: "preferences.toolbar.appearance")

            toolbarItem = item
        case .editingBehavior:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = NSLocalizedString("editing-behavior", comment: "Preferences Toolbar Appearance Button Label")
            item.paletteLabel = item.label
            item.toolTip = item.label
            item.target = self
            item.action = #selector(showEditingBehavior(_:))
            item.image = NSImage(named: "preferences.toolbar.editor")

            toolbarItem = item
        case .extensions:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "Extensions"
            item.paletteLabel = item.label
            item.toolTip = item.label
            item.target = self
            item.action = #selector(showExtensions(_:))
            item.image = NSImage(systemSymbolName: "puzzlepiece.extension", accessibilityDescription: "Extensions")

            toolbarItem = item
        case .commandLine:
            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            item.label = "Command Line"
            item.paletteLabel = item.label
            item.toolTip = item.label
            item.target = self
            item.action = #selector(showCommandLine(_:))
            item.image = NSImage(named: "terminal")

            toolbarItem = item
        default:
            break
        }

        return toolbarItem
    }

    public func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.extensions]
    }

    public func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }

    public func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return toolbarDefaultItemIdentifiers(toolbar)
    }
}
