//
//  NSEvent.ModifierFlags.swift
//  Ribbon 🎀
//
//  Created by Chris Zielinski on 7/24/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

#if canImport(AppKit)
import AppKit

extension NSEvent.ModifierFlags {

    // MARK: - Computed Properties

    var deviceIndependent: NSEvent.ModifierFlags {
        return intersection(.deviceIndependentFlagsMask)
    }

    // MARK: - Initializers

    init(modifiers: [RibbonToolbarConfiguration.KeyEquivalentModifier]?) {
        self.init(modifiers?.map({ $0.bridge }) ?? [])
    }

}
#endif
