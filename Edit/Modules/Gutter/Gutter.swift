import SwiftUI

import TextSystem
import UIUtility

public struct Gutter: View {
	private let textSystem: TextViewSystem

	public init(textSystem: TextViewSystem) {
		self.textSystem = textSystem
	}
	
    public var body: some View {
		ZStack {
			LineNumberView(textSystem: textSystem)
				.padding(EdgeInsets(top: 0.0, leading: 4.0, bottom: 0.0, trailing: 2.0))
		}
		.ignoresSafeArea()
    }
}

//#Preview {
//    Gutter()
//}
