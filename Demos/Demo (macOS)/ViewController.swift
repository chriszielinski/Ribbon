//
//  ViewController.swift
//  Demo (macOS)
//
//  Created by Chris Zielinski on 7/18/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

import AppKit
import Ribbon

class ViewController: NSViewController {

    // MARK: - Stored Properties

    // MARK: Outlets

    @IBOutlet
    var textView: NSTextView!

    // MARK: Constant

    let ribbonTarget: RibbonTarget = RibbonTarget()

    // MARK: Variable

    var ribbon: Ribbon!

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        textView.string = "Hi 👋"
        // swiftlint:disable next force_try
        ribbon = try! Ribbon.loadFromMainBundle(target: ribbonTarget, delegate: self)

        if let formatMenuItem = NSApp.mainMenu?.item(withTitle: "Format") {
            ribbon.menuItems.forEach({ formatMenuItem.submenu?.addItem($0) })
        }

        super.viewDidLoad()
    }

    override func viewWillAppear() {
        view.window!.toolbar = ribbon.toolbar

        super.viewWillAppear()
    }

    override func viewWillLayout() {
        textView.enclosingScrollView!.appearance = view.window!.effectiveAppearance

        super.viewWillLayout()
    }

}

// MARK: - RibbonDelegate Protocol

extension ViewController: RibbonDelegate {

    func ribbon(didDecode item: RibbonItem) {
        switch item.identifier {
        case .pushItem:
            item.attributedTitle
                .addAttribute(.font,
                              value: NSFont.systemFont(ofSize: NSFont.systemFontSize(for: .regular),
                                                       weight: .bold),
                              range: NSRange(location: 0, length: item.attributedTitle.length))
            item.didChangeItem()
        default: ()
        }
    }

    func ribbon(imageForIdentifier itemIdentifier: RibbonItem.Identifier, imageName: String) -> Image? {
        return nil
    }

}
