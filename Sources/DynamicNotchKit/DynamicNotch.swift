//
//  DynamicNotch.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-24.
//

import SwiftUI

public class DynamicNotch: ObservableObject {
    public var content: AnyView
    public var windowController: NSWindowController? // In case user wants to modify the NSPanel

    @Published public var isVisible: Bool = false
    @Published var isMouseInside: Bool = false
    @Published var notchWidth: CGFloat = 250
    @Published var notchHeight: CGFloat = 40

    private var timer: Timer?
    private let animationDuration: Double = 0.4

    private var animation: Animation {
        return .easeInOut(duration: animationDuration)
    }

    /// Makes a new DynamicNotch with custom content.
    /// - Parameters:
    ///   - content: A SwiftUI View
    public init(content: some View = EmptyView()) {
        self.content = AnyView(content)
        self.autoShowNotchIfNeeded()
    }

    // MARK: Public methods

    /// Set this DynamicNotch's content with animation.
    /// - Parameter content: A SwiftUI View
    public func setContent(content: some View) {
        withAnimation(animation) {
            self.content = AnyView(content)
            if let windowController {
                windowController.window?.contentView = NSHostingView(rootView: NotchView(dynamicNotch: self))
            }
        }
    }

    /// Show the DynamicNotch.
    /// - Parameters:
    ///   - screen: Screen to show on. Default is the primary screen.
    ///   - time: Time to show in seconds. If 0, the DynamicNotch will stay visible until `hide()` is called.
    public func show(on screen: NSScreen = NSScreen.screens[0], for time: Double = 0) {
        if isVisible { return }
        timer?.invalidate()

        initializeWindow(screen: screen)

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

    /// Show the DynamicNotch for a specified duration and then hide it.
    /// - Parameters:
    ///   - content: The content to display in the notch.
    ///   - duration: The time in seconds to show the content.
    public func showFor(content: some View, duration: Double) {
        setContent(content: content)
        show()

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.setContent(content: EmptyView())
            self.setNotchSize(width: 250, height: 40)
        }
    }

    /// Hide the DynamicNotch.
    public func hide() {
        guard isVisible else { return }

        guard !isMouseInside else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.hide()
            }
            return
        }

        withAnimation(animation) {
            self.isVisible = false
        }

        timer = Timer.scheduledTimer(
            withTimeInterval: animationDuration * 2,
            repeats: false
        ) { _ in
            self.deinitializeWindow()
        }
    }

    /// Toggle the DynamicNotch's visibility.
    public func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }

    /// Set the size of the notch with animation.
    /// - Parameters:
    ///   - width: The width of the notch.
    ///   - height: The height of the notch.
    public func setNotchSize(width: CGFloat, height: CGFloat) {
        withAnimation(animation) {
            notchWidth = width
            notchHeight = height
            if let windowController {
                windowController.window?.contentView = NSHostingView(rootView: NotchView(dynamicNotch: self))
            }
        }
    }

    /// Check if the cursor is inside the screen's notch area.
    /// - Returns: If the cursor is inside the notch area.
    public static func checkIfMouseIsInNotch() -> Bool {
        guard let screen = NSScreen.screenWithMouse else {
            return false
        }
        let notchSize = DynamicNotch.getNotchSize(screen: screen)

        let notchRect: NSRect = .init(
            x: screen.frame.midX - (notchSize.width / 2),
            y: screen.frame.maxY - notchSize.height + 1,
            width: notchSize.width,
            height: notchSize.height + 1
        )

        return NSMouseInRect(NSEvent.mouseLocation, notchRect, true)
    }

    // MARK: Private methods

    private static func getNotchSize(screen: NSScreen) -> CGSize {
        if let topLeftNotchpadding: CGFloat = screen.auxiliaryTopLeftArea?.width,
           let topRightNotchpadding: CGFloat = screen.auxiliaryTopRightArea?.width {
            let notchHeight = screen.safeAreaInsets.top
            let notchWidth = screen.frame.width - topLeftNotchpadding - topRightNotchpadding + 10 // 10 is for the top rounded part of the notch
            return .init(width: notchWidth, height: notchHeight)
        }

        // here we assign the menubar height, so that the method checkIfMouseIsInNotch still works
        let menuBarHeight = screen.frame.maxY - screen.visibleFrame.maxY
        let notchWidth: CGFloat = 300
        return .init(width: notchWidth, height: menuBarHeight)
    }

    private func refreshNotchSize(_ screen: NSScreen) {
        let notchSize = DynamicNotch.getNotchSize(screen: screen)
        notchWidth = notchSize.width
        notchHeight = notchSize.height
    }

    private func initializeWindow(screen: NSScreen) {
        // so that we don't have a duplicate window
        deinitializeWindow()

        refreshNotchSize(screen)

        let view: NSView = NSHostingView(rootView: NotchView(dynamicNotch: self))

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

        DispatchQueue.main.async {
            panel.setFrame(
                NSRect(
                    x: screen.frame.origin.x,
                    y: screen.frame.origin.y,
                    width: screen.frame.width,
                    height: screen.frame.height
                ),
                display: false
            )
        }

        windowController = .init(window: panel)
    }

    private func deinitializeWindow() {
        guard let windowController else { return }
        windowController.close()
        self.windowController = nil
    }

    private func autoShowNotchIfNeeded() {
        if !hasNotch() {
            show()
        }
    }

    private func hasNotch() -> Bool {
        if let screen = NSScreen.screens.first {
            return screen.auxiliaryTopLeftArea != nil && screen.auxiliaryTopRightArea != nil
        }
        return false
    }
}

