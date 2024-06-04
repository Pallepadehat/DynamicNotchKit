import SwiftUI

public class DynamicNotch: ObservableObject {
    public var content: AnyView
    public var windowController: NSWindowController?

    @Published public var isVisible: Bool = false
    @Published var isMouseInside: Bool = false
    @Published var notchWidth: CGFloat = 0
    @Published var notchHeight: CGFloat = 0
    @Published var notchStyle: Style = .notch
    @Published public var isPersistent: Bool = false
    @Published public var isExpanded: Bool = false

    private var timer: Timer?
    private let animationDuration: Double = 0.4

    private var animation: Animation {
        if #available(macOS 14.0, *), notchStyle == .notch {
            return Animation.spring(.bouncy(duration: 0.4))
        } else {
            return Animation.timingCurve(0.16, 1, 0.3, 1, duration: 0.7)
        }
    }

    private let autoManageNotchStyle: Bool
    public enum Style {
        case notch
        case floating
        case small // New style
    }

    public init<Content: View>(content: Content, style: DynamicNotch.Style! = nil) {
        self.content = AnyView(content)

        if style == nil {
            self.autoManageNotchStyle = true
        } else {
            self.autoManageNotchStyle = false
            self.notchStyle = style
        }
    }

    public func setContent<Content: View>(content: Content) {
        self.content = AnyView(content)
        if let windowController = self.windowController {
            windowController.window?.contentView = NSHostingView(rootView: NotchView(dynamicNotch: self))
        }
    }

    public func show(on screen: NSScreen = NSScreen.screens[0], for time: Double = 0) {
        if self.isVisible && !self.isPersistent { return }
        timer?.invalidate()

        self.initializeWindow(screen: screen)

        DispatchQueue.main.async {
            withAnimation(self.animation) {
                self.isVisible = true
            }
        }

        if time != 0 && !self.isPersistent {
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

        self.timer = Timer.scheduledTimer(
            withTimeInterval: self.animationDuration * 2,
            repeats: false
        ) { _ in
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

    public static func checkIfMouseIsInNotch() -> Bool {
        guard let screen = NSScreen.screenWithMouse else {
            return false
        }
        let notchSize = DynamicNotch.getNotchSize(screen: screen)

        let notchRect: NSRect = .init(
            x: screen.frame.midX - (notchSize.width / 2),
            y: screen.frame.maxY - notchSize.height,
            width: notchSize.width,
            height: notchSize.height
        )

        return NSMouseInRect(NSEvent.mouseLocation, notchRect, true)
    }

    private static func getNotchSize(screen: NSScreen) -> CGSize {
        if let topLeftNotchpadding: CGFloat = screen.auxiliaryTopLeftArea?.width,
           let topRightNotchpadding: CGFloat = screen.auxiliaryTopRightArea?.width {

            let notchHeight = screen.safeAreaInsets.top
            let notchWidth = screen.frame.width - topLeftNotchpadding - topRightNotchpadding + 10
            return .init(width: notchWidth, height: notchHeight)
        }

        let notchHeight = screen.frame.height - screen.visibleFrame.height
        let notchWidth: CGFloat = 220
        return .init(width: notchWidth, height: notchHeight)
    }

    private func refreshNotchSize(_ screen: NSScreen) {
        if self.autoManageNotchStyle,
           let topLeftNotchpadding: CGFloat = screen.auxiliaryTopLeftArea?.width,
           let topRightNotchpadding: CGFloat = screen.auxiliaryTopRightArea?.width {
            self.notchStyle = .notch
        } else {
            self.notchStyle = .floating
        }

        let notchSize = DynamicNotch.getNotchSize(screen: screen)
        self.notchWidth = notchSize.width
        self.notchHeight = notchSize.height
    }

    private func initializeWindow(screen: NSScreen) {
        if let windowController = windowController {
            windowController.window?.orderFrontRegardless()
            return
        }
        self.refreshNotchSize(screen)

        var view: NSView = NSHostingView(rootView: NotchView(dynamicNotch: self))

        if self.notchStyle == .floating {
            view = NSHostingView(rootView: NotchlessView(dynamicNotch: self))
        }

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

        self.windowController = .init(window: panel)
    }

    private func deinitializeWindow() {
        guard let windowController = windowController else { return }
        windowController.close()
        self.windowController = nil
    }
}
