import SwiftUI

struct NotchView: View {
    @ObservedObject var notch: DynamicNotch

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()

                VStack(spacing: 0) {
                    Spacer()
                        .frame(width: notch.notchWidth + 20, height: notch.notchHeight)
                        .background(Color.black)

                    if notch.showContent {
                        notch.content
                            .blur(radius: notch.isVisible ? 0 : 10)
                            .scaleEffect(notch.isVisible ? 1 : 0.8)
                            .padding(.horizontal, 15)
                            .frame(minHeight: 20)
                    }
                }
                .fixedSize()
                .frame(minWidth: notch.notchWidth)
                .onHover { hovering in
                    notch.isMouseInside = hovering
                }
                .background {
                    Rectangle()
                        .foregroundStyle(.black)
                        .padding(-50)
                }
                .mask {
                    GeometryReader { geometry in
                        HStack {
                            Spacer(minLength: 0)
                            NotchShape(cornerRadius: notch.isVisible ? 20 : nil)
                                .path(in: CGRect(x: 0, y: 0, width: notch.notchWidth, height: notch.notchHeight))
                                .frame(width: notch.notchWidth, height: notch.notchHeight)
                            Spacer(minLength: 0)
                        }
                    }
                }
                .shadow(color: .black.opacity(0.5), radius: notch.isVisible ? 10 : 0)

                Spacer()
            }
            Spacer()
        }
    }
}
