//
//  RibbonSegmentedControl.swift
//  Ribbon 🎀
//
//  Created by Chris Zielinski on 7/24/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

#if canImport(AppKit)
import AppKit

open class RibbonSegmentedControl: NSSegmentedControl, RibbonItemObserver {

    // MARK: - Stored Properties

    // MARK: Weak References

    public weak var item: RibbonItem?

    // MARK: - Initializers

    // MARK: Designated

    public init(item: RibbonItem) {
        self.item = item

        super.init(frame: .zero)

        segmentStyle = .texturedRounded
        trackingMode = .momentary
        action = #selector(segmentedControlAction)
        target = self

        didChangeItem()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overridden Methods

    open override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if let item = item {
            guard !item.isKeyEquivalent(event: event) else {
                item.sendAction(self, nil)
                return true
            }

            if let subitems = item.subitems {
                for (offset, subitem) in subitems.enumerated() {
                    guard !subitem.isKeyEquivalent(event: event) else {
                        selectedSegment = offset
                        performClick(nil)
                        return true
                    }
                }
            }
        }

        return super.performKeyEquivalent(with: event)
    }

    // MARK: - Action Methods

    @objc
    open func segmentedControlAction() {
        if let subitems = item?.subitems,
            selectedSegment >= 0,
            selectedSegment < subitems.count {
            subitems[selectedSegment].sendAction(self, nil)
        }
    }

    // MARK: - RibbonItemObserver Protocol

    open func didChangeItem() {
        guard let subitems = item?.subitems
            else { return }

        isHidden = item!.isHidden
        let filteredSubitems = subitems.filter { !$0.isHidden }
        segmentCount = filteredSubitems.count
        toolTip = item!.toolTip
        filteredSubitems.enumerated().forEach({ (offset, subitem) in
            subitem.control = self

            if let itemImage = subitem.image {
                setLabel("", forSegment: offset)
                setImage(itemImage, forSegment: offset)
            } else {
                setImage(nil, forSegment: offset)
                setLabel(subitem.title, forSegment: offset)
            }

            if #available(OSX 10.13, *) {
                setToolTip(subitem.toolTip, forSegment: offset)
            }
        })
    }

}
#endif
