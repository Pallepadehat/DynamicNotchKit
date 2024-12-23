//
//  NotchlessView.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2024-04-06.
//

import SwiftUI

struct NotchlessView<Content>: View where Content: View {
    @ObservedObject var dynamicNotch: DynamicNotch<Content>
    @State private var contentOffset: CGFloat = -50 // For drop animation
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()
                
                // Permanent notch background
                ZStack {
                    // Notch background
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.windowBackgroundColor))
                        .frame(width: max(dynamicNotch.contentFrame.width + 20, 200), height: max(dynamicNotch.contentFrame.height + 20, 32))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.quaternary, lineWidth: 0.5)
                        }
                    
                    // Content with drop animation
                    dynamicNotch.content()
                        .id(dynamicNotch.contentID)
                        .frame(width: dynamicNotch.contentFrame.width, height: dynamicNotch.contentFrame.height)
                        .offset(y: contentOffset)
                        .opacity(dynamicNotch.isVisible ? 1 : 0)
                        .onChange(of: dynamicNotch.isVisible) { isVisible in
                            withAnimation(dynamicNotch.animation) {
                                contentOffset = isVisible ? 0 : -50
                            }
                        }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onHover { hovering in
                    dynamicNotch.isMouseInside = hovering
                }
                
                Spacer()
            }
            .frame(height: max(dynamicNotch.contentFrame.height + 20, 32))
            
            Spacer()
        }
    }
}
