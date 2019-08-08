//
//  RibbonColor.swift
//  Ribbon 🎀
//
//  Created by Chris Zielinski on 7/29/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public typealias RibbonColor = UIColor

extension RibbonColor {

    // MARK: - Stored Properties

    // MARK: Type

    public static let lightRibbonBorder = RibbonColor(white: 0.678, alpha: 1)
    public static let darkRibbonBorder = RibbonColor(white: 0.4, alpha: 1)

    public static let lightButtonBackground = RibbonColor(white: 0.89, alpha: 1)
    public static let lightButtonBorder = RibbonColor(white: 0.89 - 0.09, alpha: 1)
    public static let lightButtonTint = RibbonColor(white: 0.4, alpha: 1)
    public static let lightButtonHighlightedTitle = RibbonColor(white: 0.4, alpha: 0.6)

    public static let darkButtonBackground = RibbonColor(white: 1 / 3, alpha: 1)
    public static let darkButtonBorder = RibbonColor(white: (1 / 3)  - 0.09, alpha: 1)
    public static let darkButtonTint: RibbonColor = .white
    public static let darkButtonHighlightedTitle = RibbonColor(white: 1, alpha: 0.6)

}
#endif
