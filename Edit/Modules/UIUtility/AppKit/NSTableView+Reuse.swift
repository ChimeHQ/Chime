import AppKit

extension NSTableView {
    /// Get or create a reusable view
    ///
    /// This also is in the Outline package.
    public func makeReusableView<T: NSView>(for identifier: NSUserInterfaceItemIdentifier, owner: Any? = nil, generator: () -> T) -> T {
        let view = makeView(withIdentifier: identifier, owner: owner)

        if let reusedView = view as? T {
            return reusedView
        }

        return generator()
    }
}
