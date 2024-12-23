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
            Animation.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.2)
        } else {
            Animation.spring(response: 0.4, dampingFraction: 0.6)
        }
    }
    
    // TODO: Move all animations to this file
} 