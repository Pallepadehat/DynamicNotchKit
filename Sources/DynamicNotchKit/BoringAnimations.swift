//
//  BoringAnimations.swift
//  DynamicNotchKit
//
//  Created by Patrick Jakobsen on 2024-04-08.
//

import Foundation
import SwiftUI

public class BoringAnimations {
    @Published var notchStyle: DynamicNotch<AnyView>.Style = .notch
    
    init() {
        self.notchStyle = .notch
    }
    
    var animation: Animation {
        if #available(macOS 14.0, *), notchStyle == .notch {
            Animation.spring(.bouncy(duration: 0.4))
        } else {
            Animation.timingCurve(0.16, 1, 0.3, 1, duration: 0.7)
        }
    }
    
    // TODO: Move all animations to this file
} 