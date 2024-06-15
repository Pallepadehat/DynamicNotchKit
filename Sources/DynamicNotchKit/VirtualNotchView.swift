//
//  VirtualNotchView.swift
//
//
//  Created by Kai Azim on 2024-06-15.
//

import SwiftUI

struct VirtualNotchView: View {
    @ObservedObject var dynamicNotch: DynamicNotch

    var body: some View {
        VStack {
            Spacer()

            NotchShape(cornerRadius: 10)
                .fill(Color.black)
                .frame(width: dynamicNotch.notchWidth, height: dynamicNotch.notchHeight)
                .shadow(color: .black.opacity(0.5), radius: dynamicNotch.isVisible ? 10 : 0)
                .overlay(
                    dynamicNotch.content
                        .padding(.top, 5)
                        .padding(.horizontal, 10)
                )

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
        .onAppear {
            dynamicNotch.notchWidth = 300
            dynamicNotch.notchHeight = 30
        }
    }
}
