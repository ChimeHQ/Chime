import SwiftUI

import DocumentContent
import UIUtility

public struct Gutter: View {
	public init() {
	}
	
    public var body: some View {
		ZStack {
			Color.yellow
			RepresentableViewController({ LineNumberViewController() })
		}
		.ignoresSafeArea()
    }
}

//#Preview {
//    Gutter()
//}
