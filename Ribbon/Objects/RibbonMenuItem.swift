//
//  RibbonMenuItem.swift
//  Ribbon 🎀
//
//  Created by Chris Zielinski on 7/27/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

#if canImport(AppKit)
import AppKit

open class RibbonMenuItem: NSMenuItem, RibbonItemObserver {

    // MARK: - Stored Properties

    // MARK: Weak References

    public weak var item: RibbonItem?

    // MARK: Variable

    public var forcingAttributedTitle: Bool
    public var ignoringKeyEquivalent: Bool

    // MARK: - Initializers

    // MARK: Designated

    public init(item: RibbonItem, ignoringKeyEquivalent: Bool = false, forcingAttributedTitle: Bool = false) {
        self.item = item
        self.forcingAttributedTitle = forcingAttributedTitle
        self.ignoringKeyEquivalent = ignoringKeyEquivalent

        super.init(title: "", action: #selector(RibbonItem.sendAction(_:_:)), keyEquivalent: "")

        target = item
        if #available(OSX 10.13, *) {
            allowsKeyEquivalentWhenHidden = true
        }

        didChangeItem()
    }

    public required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - RibbonItemObserver Protocol

    open func didChangeItem() {
        guard let item = item
            else { return }

        toolTip = item.usesToolTipInMenu ? item.toolTip : nil

        if !ignoringKeyEquivalent {
            keyEquivalent = item.keyEquivalent
            keyEquivalentModifierMask = item.keyEquivalentModifierMask
        } else {
            keyEquivalent = ""
            keyEquivalentModifierMask = []
        }

        if forcingAttributedTitle || item.usesAttributedTitleInMenu {
            title = ""
            attributedTitle = item.attributedTitle
        } else {
            attributedTitle = nil
            title = item.menuTitle ?? item.title
        }
    }

}
#endif
