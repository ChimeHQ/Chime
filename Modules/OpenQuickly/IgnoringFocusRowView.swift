import AppKit

final class IgnoringFocusRowView: NSTableRowView {
	override var isEmphasized: Bool {
		get { return true }
		set { }
	}
}
