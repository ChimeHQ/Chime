import SwiftUI

import UIUtility

struct DiagnosticsStatusBarItem: View {
	let infoCount: Int
	let warnCount: Int
	let errorCount: Int

	private let spacing: CGFloat = 4.0

	var singleKind: Bool {
		if infoCount == 0 && warnCount == 0 {
			return true
		}

		if warnCount == 0 && errorCount == 0 {
			return true
		}

		if infoCount == 0 && errorCount == 0 {
			return true
		}

		return false
	}

    var body: some View {
		StatusItem(style: .single) {
			HStack(spacing: 0.0) {
				Image(systemName: "octagon.fill")
					.modifier(BottomPushAndSlideEffect(visible: errorCount > 0))
					.padding(.trailing, warnCount > 0 ? spacing : 0.0)
				Image(systemName: "triangle.fill")
					.modifier(BottomPushAndSlideEffect(visible: warnCount > 0))
					.padding(.trailing, infoCount > 0 ? spacing : 0.0)
				Image(systemName: "circle.fill")
					.modifier(BottomPushAndSlideEffect(visible: infoCount > 0))
			}

		}
    }
}

#Preview {
	Group {
		DiagnosticsStatusBarItem(infoCount: 0, warnCount: 0, errorCount: 0)
		DiagnosticsStatusBarItem(infoCount: 0, warnCount: 0, errorCount: 1)
		DiagnosticsStatusBarItem(infoCount: 0, warnCount: 1, errorCount: 0)
		DiagnosticsStatusBarItem(infoCount: 0, warnCount: 1, errorCount: 1)
		DiagnosticsStatusBarItem(infoCount: 1, warnCount: 0, errorCount: 0)
		DiagnosticsStatusBarItem(infoCount: 1, warnCount: 0, errorCount: 1)
		DiagnosticsStatusBarItem(infoCount: 1, warnCount: 1, errorCount: 0)
		DiagnosticsStatusBarItem(infoCount: 1, warnCount: 1, errorCount: 1)
	}
}
