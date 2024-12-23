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
                    
                    // Content
                    dynamicNotch.content()
                        .id(dynamicNotch.contentID)
                        .frame(maxWidth: notchWidth - 20) // Leave some padding
                        .fixedSize()
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
            .frame(height: notchHeight)
            
            Spacer()
        }
    }
}
