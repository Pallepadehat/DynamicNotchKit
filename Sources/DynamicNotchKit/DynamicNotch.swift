import SwiftUI

public class DynamicNotch: ObservableObject {
    @Published public var isVisible: Bool = true
    @Published var isMouseInside: Bool = false
    @Published var notchWidth: CGFloat
    @Published var notchHeight: CGFloat
    @Published var content: AnyView = AnyView(EmptyView())

    private var windowController: NSWindowController?
    private let animationDuration: Double = 0.4

    private var animation: Animation {
        Animation.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.25)
    }

    public init(width: CGFloat, height: CGFloat) {
        self.notchWidth = width
        self.notchHeight = height
    }

    public func setContent<Content: View>(content: Content) {
        self.content = AnyView(content)
        if let windowController = self.windowController {
            windowController.window?.contentView = NSHostingView(rootView: NotchView(notch: self))
        }
    }

    public func show(on screen: NSScreen = NSScreen.primaryScreen) {
        if self.isVisible { return }
        self.initializeWindow(screen: screen)

        DispatchQueue.main.async {
            withAnimation(self.animation) {
                self.isVisible = true
            }
        }
    }

    public func hide() {
        guard self.isVisible else { return }

        withAnimation(self.animation) {
            self.isVisible = false
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration * 2) {
            self.deinitializeWindow()
        }
    }

    public func toggle() {
        if self.isVisible {
            self.hide()
        } else {
            self.show()
        }
    }

    private func initializeWindow(screen: NSScreen) {
        if let windowController = windowController {
            windowController.window?.orderFrontRegardless()
            return
        }

        let view: NSView = NSHostingView(rootView: NotchView(notch: self))

        let panel = NSPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )
        panel.hasShadow = false
        panel.backgroundColor = NSColor.white.withAlphaComponent(0.00001)
        panel.level = .screenSaver
        panel.collectionBehavior = .canJoinAllSpaces
        panel.contentView = view
        panel.orderFrontRegardless()

        panel.setFrame(
            NSRect(
                x: screen.frame.origin.x,
                y: screen.frame.origin.y,
                width: screen.frame.width,
                height: screen.frame.height
            ),
            display: false
        )

        self.windowController = NSWindowController(window: panel)
    }

    private func deinitializeWindow() {
        guard let windowController = windowController else { return }
        windowController.close()
        self.windowController = nil
    }
}
