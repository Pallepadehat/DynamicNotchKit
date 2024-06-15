import SwiftUI
import Cocoa

public class DynamicNotch: ObservableObject {
    @Published public var isVisible: Bool = true
    @Published var isMouseInside: Bool = false
    @Published var notchWidth: CGFloat
    @Published var notchHeight: CGFloat
    @Published var content: AnyView = AnyView(EmptyView())
    @Published var notchStyle: Style = .notch
    @Published var showContent: Bool = false

    private var windowController: NSWindowController?
    private var timer: Timer?
    private let animationDuration: Double = 0.4
    private let autoManageNotchStyle: Bool

    public enum Style {
        case notch
        case virtualNotch
    }

    private var animation: Animation {
        Animation.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.25)
    }

    public init(width: CGFloat, height: CGFloat, style: Style? = nil) {
        self.notchWidth = width
        self.notchHeight = height

        if style == nil {
            self.autoManageNotchStyle = true
        } else {
            self.autoManageNotchStyle = false
            self.notchStyle = style!
        }

        // Show the notch on application start
        DispatchQueue.main.async {
            self.show()
        }
    }

    public func setContent<Content: View>(content: Content) {
        self.content = AnyView(content)
        self.showContent = true
        if let windowController = self.windowController {
            windowController.window?.contentView = NSHostingView(rootView: NotchView(notch: self))
        }
    }

    public func show(on screen: NSScreen = NSScreen.primaryScreen, for time: Double = 0) {
        if self.isVisible { return }
        self.initializeWindow(screen: screen)

        DispatchQueue.main.async {
            withAnimation(self.animation) {
                self.isVisible = true
            }
        }

        if time != 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                self.hide()
            }
        }
    }

    public func hide() {
        guard self.isVisible else { return }

        guard !self.isMouseInside else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.hide()
            }
            return
        }

        withAnimation(self.animation) {
            self.isVisible = false
        }

        timer = Timer.scheduledTimer(withTimeInterval: animationDuration * 2, repeats: false) { _ in
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
        self.deinitializeWindow()

        if autoManageNotchStyle, DynamicNotch.hasPhysicalNotch(screen: screen) {
            notchStyle = .notch
        } else {
            notchStyle = .virtualNotch
        }

        refreshNotchSize(screen)

        let view: NSView = NSHostingView(rootView: NotchView(notch: self))

        let panel = NSPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )
        panel.hasShadow = false
        panel.backgroundColor = .clear
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
        guard let windowController = self.windowController else { return }
        windowController.close()
        self.windowController = nil
    }

    private func refreshNotchSize(_ screen: NSScreen) {
        let notchSize = DynamicNotch.getNotchSize(screen: screen)
        self.notchWidth = notchSize.width
        self.notchHeight = notchSize.height
    }

    private static func getNotchSize(screen: NSScreen) -> CGSize {
        if hasPhysicalNotch(screen: screen) {
            let notchHeight = screen.safeAreaInsets.top
            let notchWidth = screen.frame.width - (screen.auxiliaryTopLeftArea?.width ?? 0) - (screen.auxiliaryTopRightArea?.width ?? 0)
            return .init(width: notchWidth, height: notchHeight)
        } else {
            // Define virtual notch size
            let notchWidth: CGFloat = 300
            let notchHeight: CGFloat = 40
            return .init(width: notchWidth, height: notchHeight)
        }
    }

    private static func hasPhysicalNotch(screen: NSScreen) -> Bool {
        return screen.safeAreaInsets.top > 0
    }
}
