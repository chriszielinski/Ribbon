//
//  Ribbon.swift
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

open class Ribbon: RibbonShim {

    // MARK: - Type Methods

    public static func load(from bundle: Bundle, target: AnyObject?, delegate: RibbonDelegate? = nil) throws -> Ribbon {
        return Ribbon(configuration: try RibbonConfiguration.readFromBundle(bundle, delegate: delegate),
                      target: target,
                      delegate: delegate)
    }

    public static func loadFromMainBundle(target: AnyObject?, delegate: RibbonDelegate? = nil) throws -> Ribbon {
        return try load(from: .main, target: target, delegate: delegate)
    }

    // MARK: - Stored Properties

    // MARK: Type

    #if canImport(UIKit)
    private static let registerAppearance: Void = {
        let lightRibbonProxy: Ribbon
        let lightButtonProxy: RibbonButton
        if #available(iOS 12.0, *) {
            lightRibbonProxy = Ribbon.appearance(for: UITraitCollection(userInterfaceStyle: .light))
            lightButtonProxy = RibbonButton.appearance(for: UITraitCollection(userInterfaceStyle: .light))
        } else {
            lightRibbonProxy = Ribbon.appearance()
            lightButtonProxy = RibbonButton.appearance()
        }

        lightRibbonProxy.setBorderColor(RibbonColor.lightRibbonBorder)

        lightButtonProxy.backgroundColor = RibbonColor.lightButtonBackground
        lightButtonProxy.setBorderColor(RibbonColor.lightButtonBorder)
        lightButtonProxy.tintColor = RibbonColor.lightButtonTint
        lightButtonProxy.setTitleColor(RibbonColor.lightButtonTint, for: .normal)
        lightButtonProxy.setTitleColor(RibbonColor.lightButtonHighlightedTitle, for: .highlighted)

        if #available(iOS 12.0, *) {
            let darkRibbonProxy = Ribbon.appearance(for: UITraitCollection(userInterfaceStyle: .dark))
            darkRibbonProxy.setBorderColor(RibbonColor.darkRibbonBorder)

            let darkButtonProxy = RibbonButton.appearance(for: UITraitCollection(userInterfaceStyle: .dark))
            darkButtonProxy.backgroundColor = RibbonColor.darkButtonBackground
            darkButtonProxy.setBorderColor(RibbonColor.darkButtonBorder)
            darkButtonProxy.tintColor = RibbonColor.darkButtonTint
            darkButtonProxy.setTitleColor(RibbonColor.darkButtonTint, for: .normal)
            darkButtonProxy.setTitleColor(RibbonColor.darkButtonHighlightedTitle, for: .highlighted)
        }
    }()
    #endif

    // MARK: Weak References

    public weak var delegate: RibbonDelegate?
    public weak var target: AnyObject?

    // MARK: Constant

    public let items: [RibbonItem]

    // MARK: Variable

    public private(set) var configuration: RibbonConfiguration?
    #if canImport(UIKit)
    public var toolbarView: UIView!
    public var scrollView: UIScrollView!
    public var stackView: UIStackView!
    public var topBorder: CALayer?
    public var bottomBorder: CALayer?
    #endif

    // MARK: Lazy

    #if canImport(AppKit)
    public lazy var toolbar: NSToolbar = NSToolbar(ribbon: self)
    #endif

    // MARK: - Computed Properties

    #if canImport(AppKit)
    public var menuItems: [NSMenuItem] {
        return items.map {
            $0.initializeMenuItemIfNeeded()
            return $0.menuItem!
        }
    }
    #endif

    // MARK: - Initializers

    // MARK: Designated

    public init(items: [RibbonItem], target: AnyObject?, delegate: RibbonDelegate? = nil) {
        self.items = items
        self.target = target
        self.delegate = delegate

        #if canImport(UIKit)
        Ribbon.registerAppearance

        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        #else
        super.init()
        #endif

        #if canImport(UIKit)
        autoresizingMask = [.flexibleWidth, .flexibleHeight]

        stackView = createStackView()
        scrollView = createScrollView()
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
            ])

        toolbarView = createInputAccessoryView()
        addSubview(toolbarView)

        layoutIfNeeded()
        #endif

        items.forEach { $0.ribbon = self }
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Convenience

    public convenience init(configuration: RibbonConfiguration, target: AnyObject?, delegate: RibbonDelegate? = nil) {
        self.init(items: configuration.items, target: target, delegate: delegate)

        self.configuration = configuration
    }

    // MARK: - Overridden Methods

    #if canImport(UIKit)
    open override func layoutSubviews() {
        scrollView.contentSize.width = stackView.arrangedSubviews.reduce(0, {
            $0 + $1.bounds.width + 8
        })
        topBorder?.frame = CGRect(origin: toolbarView.bounds.origin,
                                  size: CGSize(width: toolbarView.bounds.width, height: 0.5))
        bottomBorder?.frame = CGRect(origin: CGPoint(x: 0, y: toolbarView.bounds.maxY - 1),
                                     size: CGSize(width: toolbarView.bounds.width, height: 0.5))

        super.layoutSubviews()
    }
    #endif

    // MARK: - Item Retrieval Methods

    open func item(withIdentifier identifier: RibbonItem.Identifier) -> RibbonItem? {
        return items.first { $0.identifier == identifier }
    }

    // MARK: - Subview Creation Methods

    #if canImport(UIKit)
    open func createInputAccessoryView() -> UIView {
        topBorder = CALayer()
        bottomBorder = CALayer()

        let visualEffectView = UIVisualEffectView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: 40))
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        visualEffectView.effect = UIBlurEffect(style: .prominent)

        visualEffectView.contentView.layer.addSublayer(topBorder!)
        visualEffectView.contentView.layer.addSublayer(bottomBorder!)
        visualEffectView.contentView.addSubview(scrollView)

        return visualEffectView
    }

    open func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: bounds.size.width, height: 40))
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)

        return scrollView
    }

    open func createStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: items.reduce([], { $0 + $1.controls }))
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 8

        return stackView
    }
    #endif

    // MARK: - Appearance Customization Methods

    #if canImport(UIKit)
    @available(iOS, introduced: 12.0, obsoleted: 13.0)
    open func setUserInterfaceStyle(_ style: UIUserInterfaceStyle) {
        let proxy = Ribbon.appearance(for: UITraitCollection(userInterfaceStyle: style))

        if let borderColor = proxy.borderColor() {
            topBorder?.backgroundColor = borderColor.cgColor
            bottomBorder?.backgroundColor = borderColor.cgColor
        }

        if style == .dark {
            (toolbarView as? UIVisualEffectView)?.effect = UIBlurEffect(style: .dark)
        } else {
            (toolbarView as? UIVisualEffectView)?.effect = UIBlurEffect(style: .prominent)
        }

        items.forEach { $0.setUserInterfaceStyle(style) }
    }
    #endif

}

// MARK: - UIAppearanceContainer Protocol

#if canImport(UIKit)
extension Ribbon {

    @objc
    public dynamic func borderColor() -> UIColor? {
        guard let cgColor = topBorder?.backgroundColor
            else { return nil }
        return UIColor(cgColor: cgColor)
    }

    @objc
    public dynamic func setBorderColor(_ color: UIColor) {
        topBorder?.backgroundColor = color.cgColor
        bottomBorder?.backgroundColor = color.cgColor
    }

}
#endif

// MARK: - UIInputViewAudioFeedback Protocol

#if canImport(UIKit)
extension Ribbon: UIInputViewAudioFeedback {

    open var enableInputClicksWhenVisible: Bool {
        return true
    }

}
#endif

// MARK: - NSToolbarDelegate Protocol

#if canImport(AppKit)
extension Ribbon: NSToolbarDelegate {

    open func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return items.compactMap({ $0.identifier }) + [.flexibleSpace, .space]
    }

    open func toolbar(_ toolbar: NSToolbar,
                      itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                      willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        return items.first(where: { $0.identifier == itemIdentifier })?.toolbarItem
    }

    open func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return configuration?.toolbar?.defaultItems?.map({ NSToolbarItem.Identifier($0) }) ?? []
    }

    open func toolbarWillAddItem(_ notification: Notification) {
        NSApp.mainWindow?.layoutIfNeeded()
    }

    open func toolbarDidRemoveItem(_ notification: Notification) {
        NSApp.mainWindow?.layoutIfNeeded()
    }

}
#endif
