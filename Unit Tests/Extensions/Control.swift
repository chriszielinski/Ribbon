//
//  Control.swift
//  Ribbon
//
//  Created by Chris Zielinski on 8/2/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

import Ribbon
import XCTest

extension Control {

    func press() {
        #if canImport(UIKit)
        if let button = self as? RibbonButton {
            button.isHighlighted = true
            button.sendActions(for: .touchDown)
            XCTAssertTrue(button.isHighlighted)

            button.sendActions(for: .touchUpInside)
            button.isHighlighted = false
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.2))
            XCTAssertFalse(button.isHighlighted)
        }
        #else
        performClick(nil)
        #endif
    }

    #if canImport(UIKit)
    var image: Image? {
        return image(for: .normal)
    }

    var title: String? {
        return title(for: .normal)
    }

    var attributedTitle: NSAttributedString? {
        return attributedTitle(for: .normal)
    }
    #endif

}
