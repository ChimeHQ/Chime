import Foundation
import SwiftUI

import ChimeKit

@main
final class UIPlaceholderExtension: SidebarChimeUIExtension {
    required nonisolated init() {
    }

    func acceptHostConnection(_ host: HostProtocol) throws {
    }

    var configuration: ExtensionConfiguration {
        return ExtensionConfiguration()
    }

    var applicationService: some ApplicationService {
        get throws {
			ApplicationServicePlaceholder()
        }
    }

    var scene: some ChimeExtensionScene {
//        AppExtensionSceneGroup {
            return SidebarScene {
                VStack(alignment: .center) {
                    Rectangle().frame(width: nil, height: 4).foregroundColor(.red)
                    Spacer()
                    PlaceholderView()
                    Spacer()
                    Rectangle().frame(width: nil, height: 4).foregroundColor(.red)
                }
            }
//        }
    }
}

struct PlaceholderView: View {
    @State private var angle: Angle = .degrees(0.0)

    var foreverAnimation: Animation {
        Animation.linear(duration: 25.0)
            .repeatForever(autoreverses: false)
    }

    var text: AttributedString {
        return try! AttributedString(markdown:"Native extensions, written in **Swift** and **SwiftUI**")
    }

    var body: some View {
        ZStack {
            PolygonShape.hexagon
                .stroke(Color.gray, lineWidth: 1)
                .rotationEffect(angle)
                .frame(width: 45.0, height: 45.0)
                .offset(x: -30.0, y: 30.0)
            Text(text)
            PolygonShape.hexagon
                .stroke(Color.gray, lineWidth: 1)
                .rotationEffect(angle)
                .frame(width: 75.0, height: 75.0)
                .offset(x: 10.0, y: -100.0)
        }
        .frame(width: 120.0)
        .onAppear {
            DispatchQueue.main.async {
                withAnimation(self.foreverAnimation) {
                    self.angle = .degrees(360.0)
                }
            }
        }
    }
}

struct PolygonShape: Shape {
    var sides: Int

    func path(in rect: CGRect) -> Path {
        // hypotenuse
        let h = Double(min(rect.size.width, rect.size.height)) / 2.0

        // center
        let c = CGPoint(x: rect.size.width / 2.0, y: rect.size.height / 2.0)

        var path = Path()

        for i in 0..<sides {
            let angle = (Double(i) * (360.0 / Double(sides))) * Double.pi / 180

            // Calculate vertex position
            let pt = CGPoint(x: c.x + CGFloat(cos(angle) * h), y: c.y + CGFloat(sin(angle) * h))

            if i == 0 {
                path.move(to: pt) // move to first vertex
            } else {
                path.addLine(to: pt) // draw line to next vertex
            }
        }

        path.closeSubpath()

        return path
    }

    static let hexagon = PolygonShape(sides: 6)
}

