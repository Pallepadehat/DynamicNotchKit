//
//  VirtualNotchView.swift
//  DynamicNotchApp
//
//  Created by Kai Azim on 2024-04-06.
//

import SwiftUI

struct VirtualNotchView: View {
    @ObservedObject var dynamicNotch: DynamicNotch

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()

                dynamicNotch.content
                    .frame(width: dynamicNotch.notchWidth, height: dynamicNotch.notchHeight)
                    .fixedSize()
                    .onHover { hovering in
                        dynamicNotch.isMouseInside = hovering
                    }
                    .background {
                        VisualEffectView(material: .popover, blendingMode: .behindWindow)
                            .overlay {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .strokeBorder(.quaternary, lineWidth: 1)
                            }
                    }
                    .clipShape(.rect(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.5), radius: dynamicNotch.isVisible ? 10 : 0)
                    .padding(20)

                Spacer()
            }
            Spacer()
        }
    }
}



