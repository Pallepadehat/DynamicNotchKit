//
//  DynamicNotch.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2023-08-24.
//

import Combine
import SwiftUI

// MARK: - DynamicNotch

public class DynamicNotch<Content>: ObservableObject where Content: View {

    public var windowController: NSWindowController? // Make public in case user wants to modify the NSPanel

    // Content Properties
    @Published var content: () -> Content
    @Published var contentID: UUID
    @Published var isVisible: Bool = false // Used to animate the fading in/out of the user's view

    // Notch Size
    @Published var notchWidth: CGFloat = 0
    @Published var notchHeight: CGFloat = 0
    @Published var contentFrame: CGSize = .init(width: 300, height: 32)

    // Notch Closing Properties
    @Published var isMouseInside: Bool = false // If the mouse is inside, the notch will not auto-hide
    private var timer: Timer?
    var workItem: DispatchWorkItem?
    private var subscription: AnyCancellable?

    // Notch Style
    private var notchStyle: Style = .notch
    public enum Style {
        case notch
        case floating
        case auto
    }

    private var maxAnimationDuration: Double = 0.8 // This is a timer to de-init the window after closing
    var animation: Animation {
                dynamicAnimations.animation
    }

    private var dynamicAnimations: DynamicAnimations

    /// Makes a new DynamicNotch with custom content and style.
    /// - Parameters:
    ///   - content: A SwiftUI View
    ///   - style: The popover's style. If unspecified, the style will be automatically set according to the screen.
    public init(contentID: UUID = .init(), style: DynamicNotch.Style = .auto, @ViewBuilder content: @escaping () -> Content) {
        self.contentID = contentID
        self.content = content
        self.notchStyle = style
        self.dynamicAnimations = DynamicAnimations()
        
        // Get initial content frame size
        let hostingController = NSHostingController(rootView: content())
        hostingController.view.frame = NSRect(x: 0, y: 0, width: 0, height: 0)
        hostingController.view.layoutSubtreeIfNeeded()
        let size = hostingController.view.fittingSize
        self.contentFrame = CGSize(width: size.width + 30, height: size.height + 30) // Add padding
        
        self.subscription = NotificationCenter.default
            .publisher(for: NSApplication.didChangeScreenParametersNotification)
            .sink { [weak self] _ in
                guard let self, let screen = NSScreen.screens.first else { return }
                initializeWindow(screen: screen)
            }
    }
}

// MARK: - Public

public extension DynamicNotch {

    /// Set this DynamicNotch's content.
    /// - Parameter content: A SwiftUI View
    func setContent(contentID: UUID = .init(), content: @escaping () -> Content) {
        self.content = content
        self.contentID = .init()
    }

    /// Show the DynamicNotch.
    /// - Parameters:
    ///   - screen: Screen to show on. Default is the primary screen.
    ///   - time: Time to show in seconds. If 0, the DynamicNotch will stay visible until `hide()` is called.
    func show(on screen: NSScreen = NSScreen.screens[0], for time: Double = 0) {
        func scheduleHide(_ time: Double) {
            let workItem = DispatchWorkItem { self.hide() }
            self.workItem = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: workItem)
        }

        guard !isVisible else {
            if time > 0 {
                self.workItem?.cancel()
                scheduleHide(time)
            }
            return
        }
        timer?.invalidate()

        initializeWindow(screen: screen)

        DispatchQueue.main.async {
            withAnimation(self.animation) {
                self.isVisible = true
            }
        }

        if time != 0 {
            self.workItem?.cancel()
            scheduleHide(time)
        }
    }

    /// Show the DynamicNotch with a specific size.
    /// - Parameters:
    ///   - screen: Screen to show on. Default is the primary screen.
    ///   - time: Time to show in seconds. If 0, the DynamicNotch will stay visible until `hide()` is called.
    ///   - width: The width of the content. If nil, uses the default or current width.
    ///   - height: The height of the content. If nil, uses the default or current height.
    func show(on screen: NSScreen = NSScreen.screens[0], for time: Double = 0, width: CGFloat? = nil, height: CGFloat? = nil) {
        if let width = width {
            contentFrame.width = width
        }
        if let height = height {
            contentFrame.height = height
        }
        show(on: screen, for: time)
    }

    /// Hide the DynamicNotch.
    func hide(ignoreMouse: Bool = false) {
        guard isVisible else { return }

        if !ignoreMouse, isMouseInside {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.hide()
            }
            return
        }

        withAnimation(animation) {
            self.isVisible = false
        }

        timer = Timer.scheduledTimer(withTimeInterval: maxAnimationDuration, repeats: false) { _ in
            self.deinitializeWindow()
        }
    }

    /// Toggle the DynamicNotch's visibility.
    func toggle() {
        if isVisible {
            hide()
        } else {
            show()
        }
    }

    /// Check if the cursor is inside the screen's notch area.
    /// - Returns: If the cursor is inside the notch area.
    static func checkIfMouseIsInNotch() -> Bool {
        guard let screen = NSScreen.screenWithMouse else {
            return false
        }

        let notchWidth: CGFloat = 300
        let notchHeight: CGFloat = screen.frame.maxY - screen.visibleFrame.maxY // menubar height

        let notchFrame = screen.notchFrame ?? NSRect(
            x: screen.frame.midX - (notchWidth / 2),
            y: screen.frame.maxY - notchHeight,
            width: notchWidth,
            height: notchHeight
        )

        return notchFrame.contains(NSEvent.mouseLocation)
    }
}

// MARK: - Private

extension DynamicNotch {

    func refreshNotchSize(_ screen: NSScreen) {
        if let notchSize = screen.notchSize {
            notchWidth = notchSize.width
            notchHeight = notchSize.height
        } else {
            notchWidth = 300
            notchHeight = screen.frame.maxY - screen.visibleFrame.maxY // menubar height
        }
    }

    func initializeWindow(screen: NSScreen) {
        // so that we don't have a duplicate window
        deinitializeWindow()

        refreshNotchSize(screen)

        let view: NSView = {
            switch notchStyle {
            case .notch: NSHostingView(rootView: NotchView(dynamicNotch: self).foregroundStyle(.white))
            case .floating: NSHostingView(rootView: NotchlessView(dynamicNotch: self))
            case .auto: screen.hasNotch ? NSHostingView(rootView: NotchView(dynamicNotch: self).foregroundStyle(.white)) : NSHostingView(rootView: NotchlessView(dynamicNotch: self))
            }
        }()

        let panel = DynamicNotchPanel(
            contentRect: .zero,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: true
        )
        panel.contentView = view
        panel.orderFrontRegardless()
        panel.setFrame(screen.frame, display: false)

        windowController = .init(window: panel)
    }

    func deinitializeWindow() {
        guard let windowController else { return }
        windowController.close()
        self.windowController = nil
    }
}
