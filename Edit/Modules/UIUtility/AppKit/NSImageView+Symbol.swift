import AppKit

public extension NSImageView {
    convenience init(systemSymbolName symbolName: String, accessibilityDescription description: String? = nil) {
        if let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: description) {
            self.init(image: image)
        } else {
            self.init()
        }
    }
}
