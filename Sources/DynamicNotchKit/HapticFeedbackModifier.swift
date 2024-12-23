//
//  HapticFeedbackModifier.swift
//  DynamicNotchKit
//
//  Created by Patrick Jakobsen on 2024-04-08.
//

import SwiftUI
import AppKit

struct HapticFeedbackModifier: ViewModifier {
    let feedbackType: NSHapticFeedbackManager.FeedbackPattern
    
    func body(content: Content) -> some View {
        content.onHover { isHovered in
            if isHovered {
                NSHapticFeedbackManager.defaultPerformer.perform(feedbackType, performanceTime: .default)
            }
        }
    }
}

extension View {
    func hapticFeedback(_ pattern: NSHapticFeedbackManager.FeedbackPattern = .alignment) -> some View {
        modifier(HapticFeedbackModifier(feedbackType: pattern))
    }
} 