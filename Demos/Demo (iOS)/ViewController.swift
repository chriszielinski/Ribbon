//
//  ViewController.swift
//  Demo (iOS)
//
//  Created by Chris Zielinski on 7/26/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

import UIKit
import Ribbon

class ViewController: UIViewController {

    // MARK: - Stored Properties

    // MARK: Type

    #if canImport(UIKit)
    private static let registerAppearance: Void = {
        if #available(iOS 12.0, *) {
            let lightTextViewProxy = UITextView.appearance(for: UITraitCollection(userInterfaceStyle: .light))
            let darkTextViewProxy = UITextView.appearance(for: UITraitCollection(userInterfaceStyle: .dark))

            lightTextViewProxy.tintColor = nil
            lightTextViewProxy.textColor = .darkText
            lightTextViewProxy.backgroundColor = .white

            darkTextViewProxy.tintColor = .white
            darkTextViewProxy.textColor = .white
            darkTextViewProxy.backgroundColor = UIColor(white: 1/6, alpha: 1)

            let lightNavigationBarProxy = UINavigationBar.appearance(for: UITraitCollection(userInterfaceStyle: .light))
            let darkNavigationBarProxy = UINavigationBar.appearance(for: UITraitCollection(userInterfaceStyle: .dark))

            lightNavigationBarProxy.tintColor = nil

            darkNavigationBarProxy.tintColor = .white

            #if !IOS13
            lightNavigationBarProxy.barStyle = .default
            darkNavigationBarProxy.barStyle = .black
            #endif
        }
    }()
    #endif

    // MARK: Outlets

    @IBOutlet
    weak var textView: UITextView!

    // MARK: Constant

    let ribbonTarget: RibbonTarget = RibbonTarget()

    // MARK: Variable

    var ribbon: Ribbon!

    // MARK: Overridden

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return super.preferredStatusBarStyle
        } else if #available(iOS 12.0, *) {
            return userInterfaceStyle == .light ? .default : .lightContent
        } else {
            return .default
        }
    }

    // MARK: - Computed Properties

    @available(iOS 12.0, *)
    var userInterfaceStyle: UIUserInterfaceStyle {
        #if IOS13
        if #available(iOS 13.0, *) {
            return navigationController?.overrideUserInterfaceStyle ?? traitCollection.userInterfaceStyle
        }
        #endif

        return overrideTraitCollection(forChild: self)?.userInterfaceStyle ?? traitCollection.userInterfaceStyle
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        ViewController.registerAppearance

        title = "Ribbon 🎀 Demo"
        // swiftlint:disable:next force_try
        ribbon = try! Ribbon.loadFromMainBundle(target: ribbonTarget, delegate: self)

        textView.text = "Hi 👋"
        textView.inputAccessoryView = ribbon

        if #available(iOS 12.0, *) {
            let item = UIBarButtonItem(image: "💡".emojiToImage(size: 25),
                                       style: .plain,
                                       target: self,
                                       action: #selector(bulbBarButtonItemAction))
            navigationController?.navigationBar.topItem?.rightBarButtonItem = item
        }

        super.viewDidLoad()
    }

    override func viewWillLayoutSubviews() {
        if #available(iOS 12.0, *) {
            setUserInterfaceStyle(traitCollection.userInterfaceStyle)
        }

        super.viewWillLayoutSubviews()
    }

    // MARK: - Action Methods

    @objc
    @available(iOS 12.0, *)
    func bulbBarButtonItemAction() {
        setUserInterfaceStyle(userInterfaceStyle == .dark ? .light: .dark)
        setNeedsStatusBarAppearanceUpdate()

        // Important!
        textView.reloadInputViews()
    }

    // MARK: - Appearance Customization Methods

    @available(iOS 12.0, *)
    func setUserInterfaceStyle(_ style: UIUserInterfaceStyle) {
        view.window?.backgroundColor = style == .dark ? .black : .white

        if #available(iOS 13.0, *) {
            // Handled by new `UIAppearence` functionality.
            #if IOS13
            navigationController?.overrideUserInterfaceStyle = style
            navigationController?.navigationBar.overrideUserInterfaceStyle = style
            return
            #else
            navigationController?.navigationBar.titleTextAttributes = [
                .foregroundColor: style == .dark ? UIColor.white : UIColor.black
            ]
            #endif
        }

        setOverrideTraitCollection(UITraitCollection(userInterfaceStyle: style), forChild: self)

        ribbon.setUserInterfaceStyle(style)

        let textViewProxy = UITextView.appearance(for: UITraitCollection(userInterfaceStyle: style))
        textView.tintColor = textViewProxy.tintColor
        textView.textColor = textViewProxy.textColor
        textView.backgroundColor = textViewProxy.backgroundColor
        textView.keyboardAppearance = style == .dark ? .dark : .light

        let navigationBarProxy = UINavigationBar.appearance(for: UITraitCollection(userInterfaceStyle: style))
        navigationController?.navigationBar.tintColor = navigationBarProxy.tintColor
        navigationController?.navigationBar.barStyle = navigationBarProxy.barStyle
    }

}

// MARK: - RibbonDelegate Protocol

extension ViewController: RibbonDelegate {

    func ribbon(didDecode item: RibbonItem) {
        switch item.identifier {
        case .pushItem:
            item.control?.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
        default: ()
        }
    }

    #if IOS13
    func ribbon(imageForIdentifier itemIdentifier: RibbonItem.Identifier, imageName: String) -> Image? {
        switch itemIdentifier {
        case .firstActionSubitem, .secondActionSubitem:
            if #available(iOS 13.0, *) {
                return UIImage(systemName: imageName)
            }

            fallthrough
        default:
            return UIImage(named: imageName)
        }
    }

    func ribbon(contextMenuInteractionWillPresent itemIdentifier: RibbonItem.Identifier) {
        print(#function)
    }

    func ribbon(contextMenuInteractionDidEnd itemIdentifier: RibbonItem.Identifier) {
        print(#function)
    }
    #endif

}
