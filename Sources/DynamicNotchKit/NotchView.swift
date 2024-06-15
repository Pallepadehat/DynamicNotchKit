//
//  NotchView.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-24.
//

import SwiftUI

struct NotchView: View {
    @ObservedObject var dynamicNotch: DynamicNotch
    @State private var notchSize: NSSize = .zero
    @State private var showContent: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    Spacer()
                        .frame(width: notchSize.width + 20, height: notchSize.height)
                    // We add an extra 20 here because the corner radius of the top increases when shown.
                    // (the remaining 10 has already been accounted for in refreshNotchSize)

                    dynamicNotch.content
                        .opacity(dynamicNotch.isVisible ? 1 : 0)
                        .scaleEffect(dynamicNotch.isVisible ? 1 : 0.8)
                        .animation(Animation.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3).delay(0.1), value: dynamicNotch.isVisible)
                        .padding(.horizontal, 15) // Small corner radius of the TOP of the notch
                        .frame(minHeight: 20)
                        .padding(.top, showContent ? 0 : -20)
                        .animation(dynamicNotch.isVisible ? .spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.3) : .none, value: showContent)
                        .onAppear {
                            showContent = true
                        }
                        .onDisappear {
                            showContent = false
                        }
                }
                .fixedSize()
                .frame(minWidth: notchSize.width)
                .onHover { hovering in
                    dynamicNotch.isMouseInside = hovering
                }
                .background {
                    Rectangle()
                        .foregroundStyle(.black)
                        .padding(-50) // The opening/closing animation can overshoot, so this makes sure that it's still black
                }
                .mask {
                    GeometryReader { _ in // This helps with positioning everything
                        HStack {
                            Spacer(minLength: 0)
                            NotchShape(cornerRadius: dynamicNotch.isVisible ? 20 : nil)
                                .frame(
                                    width: dynamicNotch.isVisible ? nil : notchSize.width,
                                    height: dynamicNotch.isVisible ? nil : notchSize.height
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
        .onAppear {
            notchSize = .init(
                width: dynamicNotch.notchWidth,
                height: dynamicNotch.notchHeight
            )
        }
    }
}
