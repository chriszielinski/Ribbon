//
//  RibbonPopUpButton.swift
//  Ribbon 🎀
//
//  Created by Chris Zielinski on 7/24/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

#if canImport(AppKit)
import AppKit

open class RibbonPopUpButton: NSPopUpButton, RibbonItemObserver {

    // MARK: - Stored Properties

    // MARK: Weak References

    public weak var item: RibbonItem?

    // MARK: Variable

    public var unhighlightTimer: Timer?

    // MARK: - Computed Properties

    public var popUpButtonCell: NSPopUpButtonCell {
        // swiftlint:disable next force_cast
        return cell as! NSPopUpButtonCell
    }

    internal var textField: NSTextField? {
        return subviews.first(where: { $0 is NSTextField }) as? NSTextField
    }

    // MARK: - Overridden

    open override var intrinsicContentSize: NSSize {
        guard image == nil, let textField = textField
            else { return super.intrinsicContentSize }

        return NSSize(width: textField.fittingSize.width + 20,
                      height: super.intrinsicContentSize.height)
    }

    // MARK: - Initializers

    // MARK: Designated

    public init(item: RibbonItem) {
        self.item = item

        super.init(frame: .zero, pullsDown: true)

        item.initializeMenuItemIfNeeded()
        let menuItem = RibbonMenuItem(item: item,
                                      ignoringKeyEquivalent: true,
                                      forcingAttributedTitle: true)
        menuItem.image = item.image
        item.menuItems.append(menuItem)

        let newMenu = NSMenu(title: item.title)
        newMenu.addItem(menuItem)

        item.subitems?.forEach { subitem in
            subitem.initializeMenuItemIfNeeded()
            let newItem = RibbonMenuItem(item: subitem)
            subitem.menuItems.append(newItem)
            newMenu.addItem(newItem)
        }
        menu = newMenu
        bezelStyle = .texturedRounded

        popUpButtonCell.menuItem = menuItem

        didChangeItem()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overridden Methods

    open override func performKeyEquivalent(with key: NSEvent) -> Bool {
        if let item = item, item.isKeyEquivalent(event: key) {
            unhighlightTimer?.invalidate()

            highlight(true)
            item.sendAction(self, nil)

            unhighlightTimer = Timer.scheduledTimer(timeInterval: actionInterval() + 0.01,
                                                    target: self,
                                                    selector: #selector(didFireUnhighlightTimer),
                                                    userInfo: nil,
                                                    repeats: false)
            return true
        }

        return super.performKeyEquivalent(with: key)
    }

    // MARK: - Action Methods

    @objc
    open func didFireUnhighlightTimer() {
        highlight(false)
    }

    // MARK: - RibbonItemObserver Protocol

    open func didChangeItem() {
        guard let item = item
            else { return }

        if let itemImage = item.image {
            popUpButtonCell.imagePosition = .imageOnly
            popUpButtonCell.menuItem?.image = itemImage
        } else {
            popUpButtonCell.imagePosition = .noImage
            popUpButtonCell.menuItem?.image = nil

            if item.usesAttributedTitle {
                popUpButtonCell.menuItem?.image = nil
                popUpButtonCell.menuItem?.title = ""
                popUpButtonCell.menuItem?.attributedTitle = item.attributedTitle
            } else {
                popUpButtonCell.menuItem?.attributedTitle = nil
                popUpButtonCell.menuItem?.image = nil
                popUpButtonCell.menuItem?.title = item.title
            }
        }

        isHidden = item.isHidden
        keyEquivalent = item.keyEquivalent
        keyEquivalentModifierMask = item.keyEquivalentModifierMask
        toolTip = item.toolTip

        layoutSubtreeIfNeeded()
    }

}
#endif
