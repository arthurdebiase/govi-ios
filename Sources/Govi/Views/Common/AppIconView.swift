import SwiftUI

public struct AppIconView: View {
    public let urlString: String?
    public let systemImage: String
    public let fallbackBgColor: String
    public let appName: String
    public let size: CGFloat
    
    public init(
        urlString: String?,
        systemImage: String = "app.fill",
        fallbackBgColor: String = "#0284C7",
        appName: String = "",
        size: CGFloat = 44
    ) {
        self.urlString = urlString
        self.systemImage = systemImage
        self.fallbackBgColor = fallbackBgColor
        self.appName = appName
        self.size = size
    }
    
    private var cornerRadius: CGFloat {
        size * (10.0 / 44.0)
    }
    
    public var body: some View {
        Group {
            if let urlString = urlString, let url = URL(string: urlString), !urlString.isEmpty {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size, height: size)
                            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    .strokeBorder(Color(UIColor.separator).opacity(0.35), lineWidth: 0.5)
                            )
                    case .failure:
                        fallbackView
                    case .empty:
                        ZStack {
                            Color(UIColor.secondarySystemFill)
                            ProgressView()
                                .scaleEffect(0.6)
                        }
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
                    @unknown default:
                        fallbackView
                    }
                }
            } else {
                fallbackView
            }
        }
        .frame(width: size, height: size)
    }
    
    private var fallbackView: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color(hex: fallbackBgColor).opacity(0.18))
            .frame(width: size, height: size)
            .overlay(
                Image(systemName: systemImage)
                    .font(.system(size: size * 0.44, weight: .semibold))
                    .foregroundStyle(Color(hex: fallbackBgColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color(hex: fallbackBgColor).opacity(0.25), lineWidth: 0.5)
            )
    }
}
