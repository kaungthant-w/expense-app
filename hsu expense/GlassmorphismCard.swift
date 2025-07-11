//
//  GlassmorphismCard.swift
//  hsu expense
//
//  Created by kmt on 7/12/25.
//

import SwiftUI

struct GlassmorphismCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
    }
}

// MARK: - Preview
struct GlassmorphismCard_Previews: PreviewProvider {
    static var previews: some View {
        GlassmorphismCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Sample Card")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("This is a sample glassmorphism card with some content to demonstrate the styling.")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .preferredColorScheme(.light)
        
        GlassmorphismCard {
            VStack(alignment: .leading, spacing: 16) {
                Text("Sample Card (Dark)")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Text("This is a sample glassmorphism card with some content to demonstrate the styling in dark mode.")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue, Color.purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .preferredColorScheme(.dark)
    }
}
