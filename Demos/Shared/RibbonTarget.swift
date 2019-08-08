//
//  RibbonTarget.swift
//  Ribbon 🎀
//
//  Created by Chris Zielinski on 7/23/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

import Foundation

class RibbonTarget: NSObject {

    // MARK: - Action Methods

    @objc
    func pushItemHandler() {
        print("RibbonTarget.\(#function)")
    }

    @objc
    func actionItemHandler() {
        print("RibbonTarget.\(#function)")
    }

    @objc
    func firstActionSubitemHandler() {
        print("RibbonTarget.\(#function)")
    }

    @objc
    func secondActionSubitemHandler() {
        print("RibbonTarget.\(#function)")
    }

    @objc
    func segmentedItemHandler() {
        print("RibbonTarget.\(#function)")
    }

    @objc
    func firstSegmentedSubitemHandler() {
        print("RibbonTarget.\(#function)")
    }

    @objc
    func secondSegmentedSubitemHandler() {
        print("RibbonTarget.\(#function)")
    }

}
