import SwiftUI

import WindowTreatment

@Observable
final class WindowStateSynchronizationModel {
	typealias SiblingProvider = () -> [WindowStateSynchronizationModel]

	@ObservationIgnored
	var siblingProvider: SiblingProvider = { [] }

	func windowStateChanged(_ old: WindowStateObserver.State, _ new: WindowStateObserver.State) {
		print("siblings: \(siblingProvider())")
	}
}
