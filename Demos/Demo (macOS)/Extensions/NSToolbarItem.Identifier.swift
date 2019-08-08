//
//  NSToolbarItem.Identifier.swift
//  Demo (macOS)
//
//  Created by Chris Zielinski on 7/22/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

#if canImport(AppKit)
import AppKit

// MARK: - Ribbon Item Identifiers

extension NSToolbarItem.Identifier {

    // MARK: - Stored Properties

    // MARK: Type

    static let actionItem = NSToolbarItem.Identifier("action-item")
    static let firstActionSubitem = NSToolbarItem.Identifier("first-action-subitem")
    static let secondActionSubitem = NSToolbarItem.Identifier("second-action-subitem")
    static let pushItem = NSToolbarItem.Identifier("push-item")
    static let segmentedItem = NSToolbarItem.Identifier("Segmented Item")
    static let firstSegmentedSubitem = NSToolbarItem.Identifier("first-segmented-subitem")
    static let secondSegmentedSubitem = NSToolbarItem.Identifier("second-segmented-subitem")

}
#endif
