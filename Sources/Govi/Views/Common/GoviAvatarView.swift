import SwiftUI

public struct GoviAvatarView: View {
    public let size: CGFloat
    
    public init(size: CGFloat = 40) {
        self.size = size
    }
    
    public var body: some View {
        if let uiImage = UIImage(named: "GoviAvatar") {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            // Resolution-independent pure SwiftUI vector rendering of govi.svg
            ZStack {
                Circle()
                    .fill(Color(hex: "#009440"))
                    .frame(width: size, height: size)
                
                GeometryReader { geo in
                    let scale = geo.size.width / 640.0
                    ZStack {
                        // Blue central circle
                        Circle()
                            .fill(Color(hex: "#302681"))
                            .frame(width: 320 * scale, height: 320 * scale)
                            .position(x: 320 * scale, y: 240 * scale)
                            .overlay(
                                // White diagonal stripe
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
                                .fill(Color.white)
                            )
                            .clipShape(Circle())
                        
                        // Yellow lower circle
                        Circle()
                            .fill(Color(hex: "#FFCB00"))
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

fileprivate extension Color {
    init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch cleanHex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
