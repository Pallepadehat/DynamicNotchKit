//
//  NSScreen+Extensions.swift
//
//
//  Created by Kai Azim on 2024-04-06.
//

import Cocoa
import AppKit

extension NSScreen {
    public static var primaryScreen: NSScreen {
        return NSScreen.screens[0]
    }

    public static var screenWithMouse: NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        let screens = NSScreen.screens
        return screens.first { NSMouseInRect(mouseLocation, $0.frame, false) }
    }
}
