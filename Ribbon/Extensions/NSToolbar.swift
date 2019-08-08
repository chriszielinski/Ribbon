//
//  NSToolbar.swift
//  Ribbon 🎀
//
//  Created by Chris Zielinski on 7/26/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

#if canImport(AppKit)
import AppKit

extension NSToolbar {

    // MARK: - Initializers

    // MARK: Convenience

    convenience init(ribbon: Ribbon) {
        self.init(identifier: ribbon.configuration?.toolbar?.identifier ?? "Ribbon")

        if UserDefaults.standard.dictionary(forKey: "NSToolbar Configuration \(identifier)") == nil {
            if let configuration = ribbon.configuration?.toolbar {
                displayMode = configuration.displayMode?.bridge ?? .iconOnly
                isVisible = configuration.isVisible ?? true
                sizeMode = configuration.sizeMode?.bridge ?? .default

            } else {
                displayMode = .iconOnly
                isVisible = true
                sizeMode = .default
            }
        }

        allowsExtensionItems = ribbon.configuration?.toolbar?.allowsExtensionItems ?? false
        allowsUserCustomization = ribbon.configuration?.toolbar?.allowsUserCustomization ?? true
        showsBaselineSeparator = ribbon.configuration?.toolbar?.showsBaselineSeparator ?? false
        autosavesConfiguration = true
        delegate = ribbon

        ribbon.items.forEach({ $0.initializeToolbarItemIfNeeded() })
    }

}
#endif
