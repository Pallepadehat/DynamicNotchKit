//
//  NotchView.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-24.
//

import SwiftUI

struct NotchView<Content>: View where Content: View {
    @ObservedObject var dynamicNotch: DynamicNotch<Content>
    @State private var contentOffset: CGFloat = 0 // Start at normal position

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    Spacer()
                        .frame(width: dynamicNotch.notchWidth + 20, height: dynamicNotch.notchHeight)

                    dynamicNotch.content()
                        .id(dynamicNotch.contentID)
                        .frame(width: dynamicNotch.contentFrame.width, height: dynamicNotch.contentFrame.height)
                        .safeAreaInset(edge: .bottom, spacing: 0) { Color.clear.frame(height: 15) }
                        .safeAreaInset(edge: .leading, spacing: 0) { Color.clear.frame(width: 15) }
                        .safeAreaInset(edge: .trailing, spacing: 0) { Color.clear.frame(width: 15) }
                        .offset(y: dynamicNotch.isVisible ? contentOffset : -dynamicNotch.contentFrame.height)
                        .opacity(dynamicNotch.isVisible ? 1 : 0)
                        .padding(.horizontal, 15)
                }
                .fixedSize()
                .frame(minWidth: max(dynamicNotch.notchWidth, dynamicNotch.contentFrame.width))
                .onHover { hovering in
                    dynamicNotch.isMouseInside = hovering
                }
                .background {
                    Rectangle()
                        .foregroundStyle(.black)
                        .padding(-50)
                }
                .mask {
                    GeometryReader { _ in
                        HStack {
                            Spacer(minLength: 0)
                            NotchShape(cornerRadius: dynamicNotch.isVisible ? 20 : nil)
                                .frame(
                                    width: dynamicNotch.isVisible ? nil : dynamicNotch.notchWidth,
                                    height: dynamicNotch.isVisible ? nil : dynamicNotch.notchHeight
                                )
                            Spacer(minLength: 0)
                        }
                    }
                }
                .shadow(color: .black.opacity(0.5), radius: dynamicNotch.isVisible ? 10 : 0)

                Spacer()
            }
            Spacer()
        }
        .animation(dynamicNotch.animation, value: dynamicNotch.isVisible)
    }
}
