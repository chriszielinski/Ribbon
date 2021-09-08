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

    // MARK: Lazy

    #if canImport(AppKit)
    public lazy var toolbar: NSToolbar = NSToolbar(ribbon: self)
    #endif

    // MARK: - Computed Properties

    // MARK: Private

    #if canImport(UIKit)
    private var visualEffectContentView: UIView? {
        return (toolbarView as? UIVisualEffectView)?.contentView
    }
    #endif

    // MARK: Public

    #if canImport(AppKit)
    public var menuItems: [NSMenuItem] {
        return items.map {
            $0.initializeMenuItemIfNeeded()
            return $0.menuItem!
        }
    }
    #endif

    // MARK: Open

    #if canImport(UIKit)
    open var toolbarView: UIView? {
        return subviews.first
    }
    open var scrollView: UIScrollView? {
        return visualEffectContentView?.subviews.first as? UIScrollView
    }
    open var stackView: UIStackView? {
        return scrollView?.viewWithTag((\Ribbon.stackView).hashValue) as? UIStackView
    }
    open var topBorder: CALayer? {
        return visualEffectContentView?.layer.sublayer(named: String((\Ribbon.topBorder).hashValue))
    }
    open var bottomBorder: CALayer? {
        return visualEffectContentView?.layer.sublayer(named: String((\Ribbon.bottomBorder).hashValue))
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

        addSubview(createInputAccessoryView())

        if let stackView = stackView, let scrollView = scrollView {
            NSLayoutConstraint.activate([
                stackView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor),
                stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
                ])
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UITextView.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame),
                                               name: UITextView.keyboardWillChangeFrameNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidChangeFrame(notification:)),
                                               name: UITextView.keyboardDidChangeFrameNotification,
                                               object: nil)

        setNeedsLayout()
        #else
        super.init()
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

    // MARK: - Context Menu

    #if canImport(UIKit)
    var keyboardSnapshotView: UIView?

    open var wantsFullScreenForContextMenu: Bool {
        guard let window = window
            else { return traitCollection.verticalSizeClass == .compact }

        let windowHeight = window.bounds.height
        let yOriginInWindow = convert(frame, to: nil).origin.y

        return yOriginInWindow < (windowHeight / 2)
    }

    open func removeFromKeyboard() {
        guard let textView = textView, let containerView = textView.superview
            else { return }

        textView.inputAccessoryView = nil

        if wantsFullScreenForContextMenu,
            let snapshot = UIApplication.shared.keyboardWindow?
                .snapshotView(afterScreenUpdates: false) {
            keyboardSnapshotView = snapshot
            containerView.addSubview(snapshot)
        }

        containerView.addSubview(self)

        textView.reloadInputViews()

        NSLayoutConstraint.activate([
            bottomAnchorConstraint!,
            leadingAnchorConstraint!,
            trailingAnchorConstraint!
        ])
    }

    open func addToKeyboard() {
        keyboardSnapshotView?.removeFromSuperview()
        keyboardSnapshotView = nil

        removeFromSuperview()

        textView?.inputAccessoryView = self
        textView?.reloadInputViews()
    }

    open func beginContextMenuInteraction() {
        // This bit and the commented-out bit below keep the keyboard on screen, but Apple does
        // not like it; it is being kept here because it is ~super~ cool. The assertion thrown:
        // "[Assert] UITextEffectsWindow should not become key. Please file a bug to Keyboard | iOS
        // with this call stack:"
        let wantsFullScreen = wantsFullScreenForContextMenu

        removeFromKeyboard()

//        if !wantsFullScreen {
//            UIApplication.shared.keyboardWindow?.makeKeyAndVisible()
//        }
    }

    open func endContextMenuInteraction() {
        showKeyboard()
        addToKeyboard()
    }
    #endif

    // MARK: - Overridden Methods

    #if canImport(UIKit)
    public var bottomAnchorConstraint: NSLayoutConstraint?
    public var leadingAnchorConstraint: NSLayoutConstraint?
    public var trailingAnchorConstraint: NSLayoutConstraint?
    public weak var textView: UITextView?

    var presentingContextMenu = false {
        willSet {
            if newValue && hidingContextMenu {
                hidingContextMenu = false
            }
        }
    }
    var hidingContextMenu = false {
        willSet {
            if newValue && presentingContextMenu {
                presentingContextMenu = false
            }
        }
    }

    open func setKeyboard(hidden: Bool) {
        let newAlphaValue: CGFloat = hidden ? 0 : 1

        guard let keyboardWindow = UIApplication.shared.keyboardWindow,
            keyboardWindow.alpha != newAlphaValue
            else { return }

        UIView.performWithoutAnimation {
            keyboardWindow.alpha = newAlphaValue
        }
    }
    open func showKeyboard() {
        setKeyboard(hidden: false)
    }
    open func hideKeyboard() {
        setKeyboard(hidden: true)
    }

    @objc
    func keyboardWillShow(notification: Notification) {
        if keyboardSnapshotView != nil {
            if presentingContextMenu || hidingContextMenu {
                hideKeyboard()
            }
        } else {
            showKeyboard()
        }

        updateKeyboard(notification: notification)
    }

    @objc
    func keyboardWillChangeFrame(notification: Notification) {
        if traitCollection.userInterfaceIdiom == .pad {
            if keyboardSnapshotView != nil {
                if presentingContextMenu || hidingContextMenu {
                    hideKeyboard()
                }
            } else {
                showKeyboard()
            }

            updateKeyboard(notification: notification)
        }
    }

    var cachedKeyboard: RibbonKeyboard?

    @objc
    func keyboardDidChangeFrame(notification: Notification) {
        guard let info = notification.userInfo
            else { return }

        let beginFrame = (info[UITextView.keyboardFrameBeginUserInfoKey] as? CGRect)
            ?? .zero
        let endFrame = (info[UITextView.keyboardFrameEndUserInfoKey] as? CGRect)
            ?? .zero
        let keyboardFrame = endFrame != .zero ? endFrame : beginFrame
        if keyboardFrame != .zero {
            DispatchQueue.main.async {
                self.cachedKeyboard = RibbonKeyboard.current(endFrame: keyboardFrame)
            }
        }
    }

    func updateKeyboard(notification: Notification) {
        guard !hidingContextMenu, let info = notification.userInfo
            else { return }

        if let endFrame = info[UITextView.keyboardFrameEndUserInfoKey] as? CGRect,
           let window = window {
            if window.frame.height == endFrame.origin.y && keyboardSnapshotView != nil {
                // Keyboard snapshot view is visible, so do not update the constraint.
                return
            }

            if traitCollection.userInterfaceIdiom == .pad {
                if cachedKeyboard == .floating {
                    bottomAnchorConstraint?.constant = 0
                } else {
                    bottomAnchorConstraint?.constant = -(window.frame.height - endFrame.origin.y)
                        + (textView?.inputAccessoryView == nil ? 0 : bounds.height)
                }
            } else {
                bottomAnchorConstraint?.constant = -endFrame.height
                    + (textView?.inputAccessoryView == nil ? 0 : bounds.height)
            }
        }
    }

    open func add(to textView: UITextView) {
        assert(textView.superview != nil, "The `UITextView` must have a superview.")
        guard let rootView = textView.superview
            else { return }

        textView.inputAccessoryView = self

        self.textView = textView

        translatesAutoresizingMaskIntoConstraints = false

        if #available(iOS 11.0, *) {
            bottomAnchorConstraint = bottomAnchor.constraint(equalTo: rootView.bottomAnchor)
        } else {
            bottomAnchorConstraint = bottomAnchor.constraint(equalTo: rootView.bottomAnchor)
        }

        leadingAnchorConstraint = leadingAnchor.constraint(equalTo: rootView.leadingAnchor)
        trailingAnchorConstraint = trailingAnchor.constraint(equalTo: rootView.trailingAnchor)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 40)
        ])

        setNeedsLayout()
    }

    open override func layoutSubviews() {
        if let stackView = stackView, let scrollView = scrollView {
            var availableWidth = frame.width
            if #available(iOS 11.0, *) {
                availableWidth -= scrollView.safeAreaInsets.left + scrollView.safeAreaInsets.right
            }
            let size = stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

            scrollView.contentInset.left = size.width < availableWidth
                ? ((availableWidth - size.width) / 2)
                : 4
        }

        topBorder?.frame = CGRect(origin: bounds.origin,
                                  size: CGSize(width: bounds.width, height: 0.5))
        bottomBorder?.frame = CGRect(origin: CGPoint(x: 0, y: bounds.maxY - 1),
                                     size: CGSize(width: bounds.width, height: 0.5))

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
        let topBorder = CALayer()
        topBorder.name = String((\Ribbon.topBorder).hashValue)
        let bottomBorder = CALayer()
        bottomBorder.name = String((\Ribbon.bottomBorder).hashValue)

        let visualEffectView = UIVisualEffectView(frame: bounds)
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        visualEffectView.effect = UIBlurEffect(style: .prominent)

        visualEffectView.contentView.layer.addSublayer(topBorder)
        visualEffectView.contentView.layer.addSublayer(bottomBorder)
        visualEffectView.contentView.addSubview(createScrollView())

        return visualEffectView
    }

    open func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView(frame: bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.backgroundColor = .clear
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)

        scrollView.addSubview(createStackView())

        return scrollView
    }

    open func createStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: items.reduce([], { $0 + $1.controls }))
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.tag = (\Ribbon.stackView).hashValue

        return stackView
    }
    #endif

    // MARK: - Appearance Customization Methods

    #if canImport(UIKit)
    @available(iOS, introduced: 12.0, obsoleted: 13.0)
    open func setUserInterfaceStyle(_ style: UIUserInterfaceStyle) {
        let proxy = Ribbon.appearance(for: UITraitCollection(userInterfaceStyle: style))

        if let borderColor = proxy.borderColor() {
            setBorderColor(borderColor)
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
