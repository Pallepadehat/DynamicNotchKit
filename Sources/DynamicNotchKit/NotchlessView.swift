//
//  NotchlessView.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2024-04-06.
//

import SwiftUI

struct NotchlessView<Content>: View where Content: View {
    @ObservedObject var dynamicNotch: DynamicNotch<Content>
    @State var windowHeight: CGFloat = 0
    @State private var contentOffset: CGFloat = -50 // For drop animation
    
    private let notchWidth: CGFloat = 200
    private let notchHeight: CGFloat = 32
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()
                
                // Permanent notch background
                ZStack {
                    // Notch background
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.windowBackgroundColor))
                        .frame(width: notchWidth, height: notchHeight)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.quaternary, lineWidth: 0.5)
                        }
                    
                    // Content with drop animation
                    dynamicNotch.content()
                        .id(dynamicNotch.contentID)
                        .frame(maxWidth: notchWidth - 20)
                        .fixedSize()
                        .offset(y: contentOffset)
                        .opacity(dynamicNotch.isVisible ? 1 : 0)
                        .onChange(of: dynamicNotch.isVisible) { isVisible in
                            withAnimation(dynamicNotch.animation) {
                                contentOffset = isVisible ? 0 : -50
                            }
                        }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
            .frame(height: notchHeight)
            
            Spacer()
        }
    }
}
