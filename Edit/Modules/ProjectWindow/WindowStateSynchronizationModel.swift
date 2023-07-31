import SwiftUI

import Theme
import WindowTreatment

@Observable
final class WindowStateSynchronizationModel {
	typealias SiblingProvider = () -> [WindowStateSynchronizationModel]

	@ObservationIgnored
	var siblingProvider: SiblingProvider = { [] }
	var currentTheme: Theme = Theme()

	func windowStateChanged(_ old: WindowStateObserver.State, _ new: WindowStateObserver.State) {
//		print("siblings: \(siblingProvider())")
	}
}
