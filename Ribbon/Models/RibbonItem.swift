//
//  RibbonItem.swift
//  Ribbon 🎀
//
//  Created by Chris Zielinski on 7/19/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

open class RibbonItem: NSObject, Decodable, RibbonItemObserver {

    // MARK: - Declarations

    // MARK: Enumerations

    public enum CodingKeys: String, CodingKey {
        case action
        case controlKind
        case identifier
        case imageName
        case isHidden
        case subitems
        case title

        #if canImport(UIKit)
        case iOSUsesAttributedTitle
        #else
        case keyEquivalent
        case keyEquivalentModifier
        case macOSUsesAttributedTitle
        case menuTitle
        case toolTip
        case usesAttributedTitleInMenu
        case usesToolTipInMenu
        #endif
    }

    public enum ControlKind: String, Codable {
        case push
        case action
        case segmented
    }

    // MARK: Type Aliases

    #if canImport(UIKit)
    public typealias Identifier = String
    #else
    public typealias Identifier = NSToolbarItem.Identifier
    #endif

    // MARK: - Stored Properties

    // MARK: Weak References

    public weak var ribbon: Ribbon? {
        didSet { subitems?.forEach { $0.ribbon = ribbon } }
    }

    // MARK: Constant

    public let identifier: Identifier
    public let controlKind: ControlKind?
    public let subitems: [RibbonItem]?

    // MARK: Variable

    public var action: Selector
    public var control: (Control & RibbonItemObserver)?
    #if canImport(AppKit)
    public var menuItems: [RibbonMenuItem] = []
    public var toolbarItem: NSToolbarItem?
    #endif

    // MARK: Variable + Property Observer

    /// - Important: Must call `didChangeItem()` after modifying the attributed string.
    public var attributedTitle: NSMutableAttributedString {
        didSet { didChangeItem() }
    }
    public var usesAttributedTitle: Bool = true {
        didSet { didChangeItem() }
    }
    public var image: Image? {
        didSet { didChangeItem() }
    }
    public var isHidden: Bool = false {
        didSet { didChangeItem() }
    }
    #if canImport(AppKit)
    public var keyEquivalent: String = "" {
        didSet { didChangeItem() }
    }
    public var keyEquivalentModifierMask: NSEvent.ModifierFlags = [] {
        didSet { didChangeItem() }
    }
    public var menuTitle: String? {
        didSet { didChangeItem() }
    }
    public var toolTip: String? {
        didSet { didChangeItem() }
    }
    public var usesAttributedTitleInMenu: Bool = false {
        didSet { didChangeItem() }
    }
    public var usesToolTipInMenu: Bool = true {
        didSet { didChangeItem() }
    }
    #endif

    // MARK: - Computed Properties

    public var title: String {
        get { return attributedTitle.string }
        set {
            attributedTitle = NSMutableAttributedString(string: newValue)
            didChangeItem()
        }
    }
    public var hasImage: Bool {
        return image != nil
    }
    public var hasSubitems: Bool {
        return subitems != nil && !subitems!.isEmpty
    }
    #if canImport(UIKit)
    public var controls: [Control] {
        if controlKind == .segmented && hasSubitems {
            return subitems!.compactMap { $0.control }
        } else {
            return [control!]
        }
    }
    #else
    public var menuItem: NSMenuItem? {
        return menuItems.first
    }
    #endif

    // MARK: - Initializers -

    // MARK: Designated

    public init(controlKind: ControlKind,
                identifier: Identifier? = nil,
                attributedTitle: NSMutableAttributedString,
                image: Image? = nil,
                action: Selector,
                subitems: [RibbonItem]? = nil) {
        self.action = action
        self.attributedTitle = attributedTitle
        self.controlKind = controlKind
        self.identifier = identifier ?? Identifier(attributedTitle.string)
        self.image = image
        self.subitems = subitems

        super.init()

        initializeControl()
    }

    public init(subItemTitle title: NSMutableAttributedString,
                identifier: Identifier? = nil,
                image: Image? = nil,
                action: Selector) {
        self.action = action
        self.attributedTitle = title
        self.identifier = identifier ?? Identifier(title.string)
        self.image = image

        controlKind = nil
        subitems = nil
    }

    // MARK: Convenience

    public convenience init(controlKind: ControlKind,
                            identifier: Identifier? = nil,
                            title: String,
                            image: Image? = nil,
                            action: Selector,
                            subitems: [RibbonItem]? = nil) {
        self.init(controlKind: controlKind,
                  identifier: identifier,
                  attributedTitle: NSMutableAttributedString(string: title),
                  image: image,
                  action: action,
                  subitems: subitems)

        usesAttributedTitle = false
        didChangeItem()
    }

    public convenience init(subItemTitle title: String,
                            image: Image? = nil,
                            action: Selector) {
        self.init(subItemTitle: NSMutableAttributedString(string: title),
                  image: image,
                  action: action)

        usesAttributedTitle = false
        didChangeItem()
    }

    // MARK: - Decodable Protocol

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let delegate = decoder.userInfo[.ribbonDelegate] as? RibbonDelegate

        #if canImport(UIKit)
        usesAttributedTitle = try container.decodeIfPresent(.iOSUsesAttributedTitle) ?? false
        #else
        keyEquivalent = try container.decodeIfPresent(.keyEquivalent) ?? ""
        keyEquivalentModifierMask
            = NSEvent.ModifierFlags(modifiers: try container.decodeIfPresent(.keyEquivalentModifier))
        menuTitle = try container.decodeIfPresent(.menuTitle)
        toolTip = try container.decodeIfPresent(.toolTip)
        usesAttributedTitle = try container.decodeIfPresent(.macOSUsesAttributedTitle) ?? false
        usesAttributedTitleInMenu = try container.decodeIfPresent(.usesAttributedTitleInMenu) ?? false
        usesToolTipInMenu = try container.decodeIfPresent(.usesToolTipInMenu) ?? true
        #endif

        let decodedTitle: String = try container.decode(.title)
        attributedTitle = NSMutableAttributedString(string: decodedTitle)
        action = Selector(try container.decode(.action))
        controlKind = try container.decodeIfPresent(.controlKind)
        identifier = try container.decodeIfPresent(.identifier) ?? Identifier(decodedTitle)
        isHidden = try container.decodeIfPresent(.isHidden) ?? false
        subitems = try container.decodeIfPresent(.subitems)

        super.init()

        if let imageName: String = try container.decodeIfPresent(.imageName), !imageName.isEmpty {
            self.image = delegate?.ribbon?(imageForIdentifier: identifier, imageName: imageName)
                ?? Image(named: imageName)
        }

        initializeControl()

        delegate?.ribbon?(didDecode: self)
    }

    // MARK: - Initialization Methods

    open func initializeControl() {
        guard control == nil
            else { return }

        #if canImport(UIKit)
        if controlKind == .segmented && hasSubitems {
            subitems!.forEach { $0.initializeControl() }
        } else {
            control = RibbonButton(item: self)
        }
        #else
        guard let controlKind = controlKind
            else { return }

        switch controlKind {
        case .action:
            control = RibbonPopUpButton(item: self)
        case .segmented:
            guard hasSubitems
                else { fallthrough }
            control = RibbonSegmentedControl(item: self)
        case .push:
            control = RibbonButton(item: self)
        }
        #endif
    }

    #if canImport(AppKit)
    open func initializeMenuItemIfNeeded() {
        guard menuItem == nil
            else { return }

        menuItems.insert(RibbonMenuItem(item: self), at: 0)

        if hasSubitems {
            menuItem!.submenu = NSMenu(title: title)

            subitems!.forEach { subitem in
                subitem.initializeMenuItemIfNeeded()
                menuItem!.submenu!.addItem(subitem.menuItem!)
            }
        }
    }

    open func initializeToolbarItemIfNeeded() {
        guard toolbarItem == nil,
            let controlKind = controlKind
            else { return }

        initializeMenuItemIfNeeded()

        switch controlKind {
        case .segmented:
            guard hasSubitems
                else { fallthrough }

            let group = NSToolbarItemGroup(itemIdentifier: identifier)
            group.subitems = subitems!.map { subitem -> NSToolbarItem in
                let toolbarItem = NSToolbarItem(itemIdentifier: Identifier(rawValue: subitem.title))
                toolbarItem.label = subitem.title
                return toolbarItem
            }

            group.paletteLabel = title
            group.view = control
            toolbarItem = group
        default:
            toolbarItem = NSToolbarItem(itemIdentifier: identifier)
            toolbarItem!.label = title
            toolbarItem!.paletteLabel = title
            toolbarItem!.view = control
        }
    }
    #endif

    // MARK: - Helper Methods

    #if canImport(AppKit)
    func isKeyEquivalent(event: NSEvent) -> Bool {
        return event.characters == keyEquivalent
            && event.modifierFlags.deviceIndependent == keyEquivalentModifierMask
    }
    #endif

    // MARK: - Action Methods

    @objc
    open func sendAction(_ object: Any?, _ event: Any?) {
        if let target = ribbon?.target {
            #if canImport(UIKit)
            UIApplication.shared.sendAction(action, to: target, from: object, for: event as? UIEvent)
            #else
            NSApp.sendAction(action, to: target, from: object)
            #endif
        }
    }

    // MARK: - Appearance Customization Methods

    #if canImport(UIKit)
    @available(iOS, introduced: 12.0, obsoleted: 13.0)
    open func setUserInterfaceStyle(_ style: UIUserInterfaceStyle) {
        if controlKind == .segmented && hasSubitems {
            subitems!.forEach { $0.setUserInterfaceStyle(style) }
        } else {
            (control as? RibbonButton)?.setUserInterfaceStyle(style)
        }
    }
    #endif

    // MARK: - RibbonItemObserver Protocol

    open func didChangeItem() {
        control?.didChangeItem()

        #if canImport(AppKit)
        menuItems.forEach { $0.didChangeItem() }
        #endif
    }

}
