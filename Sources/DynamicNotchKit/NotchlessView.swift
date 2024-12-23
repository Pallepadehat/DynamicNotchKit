//
//  NotchlessView.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2024-04-06.
//

import SwiftUI

struct NotchlessView<Content>: View where Content: View {
    @ObservedObject var dynamicNotch: DynamicNotch<Content>
    @State private var contentOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.windowBackgroundColor))
                        .frame(width: dynamicNotch.contentFrame.width + 20, height: dynamicNotch.contentFrame.height + 20)
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(.quaternary, lineWidth: 0.5)
                        }
                    
                    dynamicNotch.content()
                        .id(dynamicNotch.contentID)
                        .frame(width: dynamicNotch.contentFrame.width, height: dynamicNotch.contentFrame.height)
                        .offset(y: dynamicNotch.isVisible ? contentOffset : -dynamicNotch.contentFrame.height)
                        .opacity(dynamicNotch.isVisible ? 1 : 0)
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onHover { hovering in
                    dynamicNotch.isMouseInside = hovering
                }
                .hapticFeedback(.alignment)
                
                Spacer()
            }
            .frame(height: dynamicNotch.contentFrame.height + 20)
            
            Spacer()
        }
        .animation(dynamicNotch.animation, value: dynamicNotch.isVisible)
    }
}
