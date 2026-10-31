import SwiftUI

public struct SuggestedActionsView: View {
    public let suggestions: [String]
    public let onSelect: (String) -> Void
    
    public init(suggestions: [String], onSelect: @escaping (String) -> Void) {
        self.suggestions = suggestions
        self.onSelect = onSelect
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button(action: {
                        HapticManager.shared.impact(.light)
                        onSelect(suggestion)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "sparkles")
                                .font(.caption2)
                            Text(suggestion)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .foregroundStyle(Color(UIColor.label))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color(UIColor.separator), lineWidth: 0.8)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }
}
