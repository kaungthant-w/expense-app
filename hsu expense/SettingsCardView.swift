// SettingsCardView.swift
import SwiftUI

struct SettingsCardView: View {
    let title: String
    let description: String
    let icon: String
    let iconColor: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            // Card layout matching Android CardView
            HStack(spacing: 16) {
                // Icon section
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 30, height: 30)
                
                // Text content section (matching Android nested LinearLayout)
                VStack(alignment: .leading, spacing: 8) { // matching Android layout_marginBottom="8dp"
                    Text(title)
                        .font(.headline) // matching Android textSize="20sp"
                        .fontWeight(.bold) // matching Android textStyle="bold"
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(description)
                        .font(.subheadline) // matching Android textSize="14sp"
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Chevron (matching Android ">" TextView)
                Image(systemName: "chevron.right")
                    .font(.title2) // matching Android textSize="24sp"
                    .foregroundColor(.secondary)
            }
            .padding(20) // matching Android padding="20dp"
            .background(
                RoundedRectangle(cornerRadius: 16) // matching Android cardCornerRadius="16dp"
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: Color.black.opacity(0.1),
                        radius: 4, // matching Android cardElevation="8dp"
                        x: 0,
                        y: 2
                    )
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }) {
            // Long press action if needed
        }
    }
}
