//
//  RibbonKeyboard.swift
//  Ribbon
//
//  Created by Chris Zielinski on 2/26/20.
//  Copyright © 2020 Big Z Labs. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public enum RibbonKeyboard: String, Equatable {
    case floating
    case split
    case docked
    case undocked

    public static func current(endFrame: CGRect) -> RibbonKeyboard? {
        guard let keyboardWindow = UIApplication.shared.keyboardWindow,
            endFrame != .zero
            else { return nil }

        guard endFrame.minY != keyboardWindow.frame.height
            // The keyboard is hidden.
            else { return nil }

        if keyboardWindow.frame.width == endFrame.width {
            if endFrame.maxY == keyboardWindow.frame.height {
                return .docked
            } else if let hitView = keyboardWindow.hitTest(CGPoint(x: endFrame.midX,
                                                                   y: endFrame.midY),
                                                           with: nil) {
                // When the hit test results in an instance of `UIKeyboardLayoutStar`, we hit a
                // usable portion of the keyboard.
                return String(describing: type(of: hitView)).hasSuffix("Star")
                    ? .undocked
                    : .split
            } else {
                return .undocked
            }
        } else if endFrame.width < keyboardWindow.frame.width {
            return .floating
        }

        return nil
    }
}
#endif
