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

    private static let registerAppearance: Void = {
        if #available(iOS 12.0, *) {
            let lightUIStyle = UITraitCollection(userInterfaceStyle: .light)
            let darkUIStyle = UITraitCollection(userInterfaceStyle: .dark)
            let lightTextViewProxy = UITextView.appearance(for: lightUIStyle)
            let darkTextViewProxy = UITextView.appearance(for: darkUIStyle)

            lightTextViewProxy.tintColor = nil
            lightTextViewProxy.textColor = .darkText
            lightTextViewProxy.backgroundColor = .white

            darkTextViewProxy.tintColor = .white
            darkTextViewProxy.textColor = .white
            darkTextViewProxy.backgroundColor = UIColor(white: 1/6, alpha: 1)

            let lightNavigationBarProxy = UINavigationBar.appearance(for: lightUIStyle)
            let darkNavigationBarProxy = UINavigationBar.appearance(for: darkUIStyle)

            lightNavigationBarProxy.tintColor = nil

            darkNavigationBarProxy.tintColor = .white

            if #available(iOS 13.0, *) { } else {
                lightNavigationBarProxy.barStyle = .default
                darkNavigationBarProxy.barStyle = .black
            }
        }
    }()

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
        if #available(iOS 13.0, *) {
            return traitCollection.userInterfaceStyle
        }

        return overrideTraitCollection(forChild: self)?.userInterfaceStyle
            ?? traitCollection.userInterfaceStyle
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        ViewController.registerAppearance

        title = "Ribbon 🎀 Demo"
        // swiftlint:disable:next force_try
        ribbon = try! Ribbon.loadFromMainBundle(target: ribbonTarget, delegate: self)

        textView.text = "Hi 👋"

        // swiftlint:disable line_length
//        textView.text = """
//            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam elementum magna pharetra justo viverra pellentesque. Vestibulum odio magna, malesuada ut lacus sed, vulputate mollis libero. Cras laoreet sit amet augue a tempor. Duis accumsan mollis nulla, ac condimentum elit placerat vel. Praesent maximus ipsum eu lacus tempus hendrerit. Nullam varius at nibh sit amet dictum. Suspendisse urna risus, tempus nec eros a, tincidunt vulputate ex. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Duis vel tellus non neque pretium malesuada nec quis nisl. In hac habitasse platea dictumst. Vestibulum malesuada, dui et ultricies iaculis, ligula lectus dapibus massa, ac malesuada nisl lorem non enim. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Etiam ut libero at turpis iaculis aliquet id eu velit. Sed eget feugiat est. Integer accumsan luctus diam quis volutpat. Quisque vel venenatis enim.
//
//            Vestibulum in mauris tristique, pulvinar sapien porta, varius urna. Vivamus eu dolor a diam vehicula varius. Mauris euismod ut orci ut sodales. Phasellus quis rhoncus lectus, id scelerisque lorem. Nulla fermentum luctus leo, id egestas ipsum facilisis non. Donec purus ex, accumsan in massa nec, sollicitudin viverra mauris. Duis posuere ex at interdum sodales. Fusce eget vulputate sem. Curabitur tempus erat sed libero pretium, in placerat enim accumsan. Aenean aliquam nulla ante, scelerisque blandit lectus tincidunt sed.
//
//            In tincidunt at magna nec rutrum. Maecenas fringilla justo sed eros finibus luctus. Nulla laoreet nisi erat, quis tempus felis vehicula sed. Pellentesque eros dolor, cursus ut tincidunt non, placerat efficitur lacus. Praesent sit amet urna ligula. In orci eros, vestibulum sed erat et, viverra scelerisque augue. Donec id aliquet mi. Phasellus dapibus arcu ex, vitae vestibulum mauris pharetra sed. Nullam scelerisque felis id eros fringilla, non rutrum eros placerat. Praesent quis ornare ante, a semper nisl. Cras pharetra neque pretium urna laoreet dapibus. In hac habitasse platea dictumst. Morbi purus purus, ultrices in rhoncus cursus, tempus sed metus. In ultricies vel nisl nec venenatis. Nunc rhoncus nisi ut condimentum dictum. Duis eget rutrum lacus.
//            """
        // swiftlint:enable line_length

        ribbon.add(to: textView)

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

        if #available(iOS 13.0, *), let window = view.window {
            // Handled by new `UIAppearence` functionality.
            window.overrideUserInterfaceStyle = style
            return
        }

        setOverrideTraitCollection(UITraitCollection(userInterfaceStyle: style), forChild: self)

        ribbon.setUserInterfaceStyle(style)

        let textViewProxy = UITextView.appearance(for: UITraitCollection(userInterfaceStyle: style))
        textView.tintColor = textViewProxy.tintColor
        textView.textColor = textViewProxy.textColor
        textView.backgroundColor = textViewProxy.backgroundColor
        textView.keyboardAppearance = style == .dark ? .dark : .light

        let uiStyleTraitCollection = UITraitCollection(userInterfaceStyle: style)
        let navigationBarProxy = UINavigationBar.appearance(for: uiStyleTraitCollection)
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

    func ribbon(imageForIdentifier itemIdentifier: RibbonItem.Identifier,
                imageName: String) -> Image? {
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
//        print(#function)
    }

    func ribbon(contextMenuInteractionDidEnd itemIdentifier: RibbonItem.Identifier) {
//        print(#function)
    }

}
