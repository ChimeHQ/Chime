import AppKit
import ExtensionFoundation

@MainActor
@Observable
final class InspectorModel {
    var selection: ExtensionList.Item?
    var items: [ExtensionList.Item] = []

    @ObservationIgnored
    private lazy var popover: NSPopover = {
        let popover = NSPopover()

        popover.behavior = .semitransient

        return popover
    }()

    func showSelectionPopover() {
        
    }
}
