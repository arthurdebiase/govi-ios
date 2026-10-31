import SwiftUI

public struct GoviAvatarView: View {
    public let colors: AgentColors
    public let size: CGFloat
    
    public init(colors: AgentColors = .default, size: CGFloat = 40) {
        self.colors = colors
        self.size = size
    }
    
    public var body: some View {
        if colors == .default, let uiImage = UIImage(named: "GoviAvatar") {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            // Vector rendering of govi.svg with custom colors
            ZStack {
                // Background circle
                Circle()
                    .fill(Color(hex: colors.background))
                    .frame(width: size, height: size)
                
                GeometryReader { geo in
                    let scale = geo.size.width / 640.0
                    ZStack {
                        // Central / Top circle
                        Circle()
                            .fill(Color(hex: colors.circle))
                            .frame(width: 320 * scale, height: 320 * scale)
                            .position(x: 320 * scale, y: 240 * scale)
                            .overlay(
                                // Curved stripe with vector clipping
                                Path { path in
                                    path.move(to: CGPoint(x: 510.777 * scale, y: 260.541 * scale))
                                    path.addCurve(
                                        to: CGPoint(x: 147.593 * scale, y: 156.816 * scale),
                                        control1: CGPoint(x: 402.241 * scale, y: 189.283 * scale),
                                        control2: CGPoint(x: 277.391 * scale, y: 153.626 * scale)
                                    )
                                    path.addLine(to: CGPoint(x: 153.634 * scale, y: 204.435 * scale))
                                    path.addCurve(
                                        to: CGPoint(x: 510.777 * scale, y: 260.541 * scale),
                                        control1: CGPoint(x: 270.452 * scale, y: 201.563 * scale),
                                        control2: CGPoint(x: 435.161 * scale, y: 260.930 * scale)
                                    )
                                    path.closeSubpath()
                                }
                                .fill(Color(hex: colors.stripe))
                            )
                            .clipShape(Circle())
                        
                        // Lower semi-circle / base
                        Circle()
                            .fill(Color(hex: colors.semiCircle))
                            .frame(width: 640 * scale, height: 640 * scale)
                            .position(x: 320 * scale, y: 760 * scale)
                    }
                }
                .clipShape(Circle())
                .frame(width: size, height: size)
            }
            .frame(width: size, height: size)
        }
    }
}
