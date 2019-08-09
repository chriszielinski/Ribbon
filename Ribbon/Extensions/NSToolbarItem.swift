//
//  NSToolbarItem.swift
//  Ribbon 🎀
//
//  Created by Chris Zielinski on 8/8/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

#if canImport(AppKit)
import AppKit

extension NSToolbarItem {

    // MARK: - Initializers

    // MARK: Convenience

    public convenience init(subitem: RibbonItem) {
        self.init(itemIdentifier: subitem.identifier)

        label = subitem.title
    }

}
#endif
