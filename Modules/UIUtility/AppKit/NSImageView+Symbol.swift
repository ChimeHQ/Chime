import NSUI

#if os(macOS)
public extension NSUIImageView {
    convenience init(systemSymbolName symbolName: String, accessibilityDescription description: String? = nil) {
        if let image = NSUIImage(systemSymbolName: symbolName, accessibilityDescription: description) {
            self.init(image: image)
        } else {
            self.init()
        }
    }
}
#endif
