import AppKit
import SwiftUI

struct ExtensionContent: NSViewControllerRepresentable {
    func makeNSViewController(context: Context) -> ExtensionContentViewController {
        ExtensionContentViewController()
    }
    
    func updateNSViewController(_ nsViewController: ExtensionContentViewController, context: Context) {
    }
}

final class ExtensionContentViewController: NSViewController {

}
