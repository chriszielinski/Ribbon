//
//  UIUserInterfaceStyle.swift
//  Ribbon
//
//  Created by Chris Zielinski on 9/7/21.
//  Copyright © 2021 Big Z Labs. All rights reserved.
//

#if canImport(UIKit)
import UIKit

@available(iOS 12.0, *)
extension UIUserInterfaceStyle: CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case .dark:
            return ".dark"
        case .light:
            return ".light"
        case .unspecified:
            return ".unspecified"
        @unknown default:
            return "unknown"
        }
    }

}
#endif
