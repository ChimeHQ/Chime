import Cocoa
import SwiftUI

import ChimeKit
//import Dusk
import WindowTreatment

public final class OpenQuicklyWindowController: NSWindowController {
    private let viewController: OpenQuicklyViewController

    private lazy var windowObserver = WindowStateObserver { [unowned self] (oldState, newState) in
        if newState.isKey == false {
            self.close()
        }
    }

    public init( context: OpenQuicklyContext, symbolQueryService: SymbolQueryService?) {
        let window = CustomizableMainKeyWindow(contentRect: .zero, styleMask: [.borderless], backing: .buffered, defer: true)

        window.hidesOnDeactivate = true
        window.canBecomeKeyValue = true
        window.canBecomeMainValue = false
        window.hasShadow = true
        window.backgroundColor = .clear
        window.title = "Open Quickly"

        self.viewController = OpenQuicklyViewController(context: context, symbolQueryService: symbolQueryService)

        super.init(window: window)

        window.initialFirstResponder = viewController.inputView
        contentViewController = viewController
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func showWindow(_ sender: Any?) {
        window?.makeFirstResponder(viewController.inputView)
        windowObserver.observe(window: window)

        super.showWindow(sender)
    }

    public func showWindow(parent: NSWindow) {
        // window.center doesn't produce great behavior, because it takes into
        // consideration the height, which is variable.

        if let screen = parent.screen {
            centerWindow(on: screen)
        } else {
            window?.center()
        }

        showWindow(self)
    }

    private func centerWindow(on screen: NSScreen) {
        guard let window = window else { return }

        let visibleFrame = screen.visibleFrame
        let frame = window.frame

        // we want the frame to be horizontally centered, and the *top* of the window
        // to be a little above the vertical center

        let x = max(visibleFrame.center.x - frame.width / 2, 0)

        let delta = visibleFrame.height * 0.2
        let limit = visibleFrame.height - frame.height

        let y = min(max(visibleFrame.center.y - frame.height + delta, 0), limit)

        window.setFrameOrigin(NSPoint(x: x, y: y))
    }

    public var symbolQueryService: SymbolQueryService? {
        get { viewController.symbolQueryService }
        set { viewController.symbolQueryService = newValue }
    }
}

//extension OpenQuicklyWindowController: Themeable {
//    public func applyTheme(_ theme: Theme) {
//        guard window?.isVisible == true else {
//            return
//        }
//
//        guard let view = contentViewController?.view else {
//            return
//        }
//
//        let themeDark = theme.isDark
//        let effectiveAppearance = view.effectiveAppearance
//        let appearanceDark = effectiveAppearance.isDark
//
//        if themeDark != appearanceDark {
//            view.appearance = effectiveAppearance.oppositeAppearance
//        }
//    }
//}
