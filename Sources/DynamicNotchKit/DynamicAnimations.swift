//
//  BoringAnimations.swift
//  DynamicNotchKit
//
//  Created by Patrick Jakobsen on 2024-04-08.
//

import Foundation
import SwiftUI

public class DynamicAnimations {
    @Published var notchStyle: DynamicNotch<AnyView>.Style = .notch
    
    init() {
        self.notchStyle = .notch
    }
    
    var animation: Animation {
        Animation.spring(response: 0.3, dampingFraction: 0.8)
    }
    
    // TODO: Move all animations to this file
} 
