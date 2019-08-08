//
//  RibbonUnitTests.swift
//  Unit Tests (macOS)
//
//  Created by Chris Zielinski on 7/30/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

import XCTest
@testable
import Ribbon

#if canImport(AppKit)
import Carbon.HIToolbox.Events
#endif

class RibbonUnitTests: XCTestCase {

    class Target: NSObject {
        let expectation: XCTestExpectation

        init(expectation: XCTestExpectation) {
            self.expectation = expectation
        }

        @objc
        func pushItemHandler() {
            expectation.fulfill()
        }

        @objc
        func actionItemHandler() {
            expectation.fulfill()
        }

        @objc
        func segmentedItemHandler() {
            expectation.fulfill()
        }

        @objc
        func firstSegmentedSubitemHandler() {
            expectation.fulfill()
        }

        @objc
        func secondSegmentedSubitemHandler() {
            expectation.fulfill()
        }
    }

    override func setUp() {
        #if canImport(AppKit)
        UserDefaults.standard.removeObject(forKey: "NSToolbar Configuration com.bigzlabs.RibbonDemo")
        #endif

        super.setUp()
    }

    func createRibbon(target: AnyObject?, delegate: RibbonDelegate? = nil) throws -> Ribbon {
        #if canImport(UIKit)
        return try Ribbon.load(from: Bundle(for: RibbonUnitTests.self), target: target, delegate: delegate)
        #else
        return try Ribbon.loadFromMainBundle(target: target, delegate: delegate)
        #endif
    }

    func testInitialization() {
        let expectation = self.expectation(description: "successfully initialized and calls the action method")

        let target = Target(expectation: expectation)
        #if canImport(UIKit)
        let title = "Item"
        #else
        let title = "Item"
        let menuTitle = "Menu title"
        let toolTip = "A tooltip!"
        #endif

        let item = RibbonItem(controlKind: .push,
                              title: title,
                              action: #selector(Target.pushItemHandler))

        #if canImport(AppKit)
        item.usesToolTipInMenu = true
        XCTAssertEqual(item.controlKind, RibbonItem.ControlKind.push)
        #endif

        let ribbon = Ribbon(items: [item], target: target)

        let ribbonItem = ribbon.item(withIdentifier: RibbonItem.Identifier(title))
        XCTAssertNotNil(ribbonItem)
        XCTAssertNotNil(ribbonItem!.control)
        XCTAssertFalse(ribbonItem!.isHidden)
        XCTAssertFalse(ribbonItem!.hasImage)

        #if canImport(AppKit)
        _ = ribbon.toolbar
        ribbonItem!.menuTitle = menuTitle
        ribbonItem!.toolTip = toolTip

        XCTAssertEqual(ribbonItem!.menuTitle, menuTitle)
        XCTAssertEqual(ribbonItem!.toolTip, toolTip)

        XCTAssertEqual(ribbonItem!.control?.toolTip, toolTip)

        let menuItem = ribbonItem!.menuItem
        XCTAssertNotNil(menuItem)
        XCTAssertEqual(menuItem!.title, menuTitle)
        XCTAssertEqual(menuItem!.toolTip, toolTip)
        #endif

        ribbonItem!.control!.press()

        waitForExpectations(timeout: 10)

        #if canImport(AppKit)
        ribbonItem!.isHidden = true
        XCTAssertTrue(ribbonItem!.isHidden)
        #endif
    }

    func testLoadConfiguration() throws {
        XCTAssertNoThrow(try createRibbon(target: nil))
    }

    func testSendsAction() throws {
        let expectation = self.expectation(description: "successfully calls the action method")

        let target = Target(expectation: expectation)
        let ribbon = try createRibbon(target: target)

        XCTAssertNotNil(ribbon.configuration)
        XCTAssertEqual(ribbon.items.count, 3)

        ribbon.item(withIdentifier: .pushItem)?.control?.press()

        waitForExpectations(timeout: 10)
    }

    func testChangeTarget() throws {
        let expectation = self.expectation(description: "successfully calls the new target's action method")

        let initialTarget = RibbonTarget()
        let ribbon = try createRibbon(target: initialTarget)

        XCTAssertEqual(ribbon.target as? NSObject, initialTarget)
        XCTAssertNotNil(ribbon.configuration)
        XCTAssertEqual(ribbon.items.count, 3)

        let target = Target(expectation: expectation)
        ribbon.target = target
        XCTAssertEqual(ribbon.target as? NSObject, target)

        ribbon.item(withIdentifier: .pushItem)?.control?.press()

        waitForExpectations(timeout: 10)
    }

    func testDelegate() throws {

        class Delegate: RibbonDelegate {
            let expectation: XCTestExpectation

            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }

            func ribbon(didDecode item: RibbonItem) {
                expectation.fulfill()
            }

            func ribbon(imageForIdentifier itemIdentifier: RibbonItem.Identifier, imageName: String) -> Image? {
                expectation.fulfill()
                return Image(named: imageName)
            }
        }

        let expectation = self.expectation(description: "successfully notifies the delegate")
        expectation.expectedFulfillmentCount = 7 + 4

        let target = RibbonTarget()
        let delegate = Delegate(expectation: expectation)
        _ = try createRibbon(target: target, delegate: delegate)

        waitForExpectations(timeout: 10)
    }

    func testModifyPushItem() throws {
        continueAfterFailure = false

        let ribbon = try createRibbon(target: nil)
        let pushItem = ribbon.item(withIdentifier: .pushItem)
        let pushButton = pushItem!.control as? RibbonButton

        XCTAssertNotNil(pushButton)

        pushItem!.image = #imageLiteral(resourceName: "chevron-left")
        XCTAssertEqual(pushButton!.image, #imageLiteral(resourceName: "chevron-left"))
        #if canImport(UIKit)
        XCTAssertNil(pushButton!.title)
        #else
        XCTAssertEqual(pushButton!.title, "")
        #endif

        let newAttributedTitle = NSMutableAttributedString(string: "Bold Push Item")
        newAttributedTitle.addAttribute(.font,
                                        value: Font.boldSystemFont(ofSize: Font.labelFontSize),
                                        range: NSRange(location: 0, length: newAttributedTitle.length))

        pushItem!.image = nil
        pushItem!.usesAttributedTitle = true
        pushItem!.attributedTitle = newAttributedTitle

        XCTAssertNil(pushButton!.image)
        #if canImport(UIKit)
        XCTAssertNil(pushButton!.title)
        #else
        XCTAssertEqual(pushButton!.title, "Bold Push Item")
        #endif
        XCTAssertEqual(pushButton!.attributedTitle, pushItem!.attributedTitle)
        XCTAssertEqual(pushButton!.attributedTitle, newAttributedTitle)

        pushItem!.usesAttributedTitle = false
        pushItem!.title = "test title"
        XCTAssertNil(pushButton!.image)
        XCTAssertEqual(pushButton!.title, "test title")
    }

    func testChangeTargetAndAction() throws {

        class TestTarget: NSObject {
            let expectation: XCTestExpectation
            var hasCalledPushItemHandler = false
            var hasCalledSecondPushItemHandler = false

            init(expectation: XCTestExpectation) {
                self.expectation = expectation
            }

            @objc
            func pushItemHandler() {
                guard !hasCalledPushItemHandler
                    else { return }
                hasCalledPushItemHandler = true
                expectation.fulfill()
            }

            @objc
            func secondPushItemHandler() {
                guard !hasCalledSecondPushItemHandler
                    else { return }
                hasCalledSecondPushItemHandler = true
                expectation.fulfill()
            }
        }

        let expectation = self.expectation(description: "successfully calls the modified action method")
        expectation.expectedFulfillmentCount = 2

        let firstTarget = TestTarget(expectation: expectation)
        firstTarget.hasCalledSecondPushItemHandler = true
        let secondTarget = TestTarget(expectation: expectation)
        secondTarget.hasCalledPushItemHandler = true

        let ribbon = try createRibbon(target: firstTarget)
        let pushItem = ribbon.item(withIdentifier: .pushItem)
        let pushButton = pushItem!.control as? RibbonButton

        XCTAssertNotNil(pushButton)

        pushButton!.press()

        ribbon.target = secondTarget
        pushItem!.action = #selector(TestTarget.secondPushItemHandler)

        pushButton!.press()

        waitForExpectations(timeout: 5)
    }

    #if canImport(AppKit)
    func testKeyEquivalentsPush() throws {
        let expectation = self.expectation(description: "push item key equivalents successfully call the action method")
        expectation.expectedFulfillmentCount = 2

        let target = Target(expectation: expectation)
        let ribbon = try Ribbon.loadFromMainBundle(target: target)

        let pushItem = ribbon.item(withIdentifier: .pushItem)
        let pushButton = pushItem!.control as? RibbonButton

        XCTAssertNotNil(pushButton)

        let pEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(kVK_ANSI_P), keyDown: false)!
        pEvent.flags = [.maskCommand, .maskShift]
        pushButton!.performKeyEquivalent(with: NSEvent(cgEvent: pEvent)!)

        pushItem!.keyEquivalent = "l"
        pushItem!.keyEquivalentModifierMask = [.command]

        let lEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(kVK_ANSI_L), keyDown: false)!
        lEvent.flags = [.maskCommand]
        pushButton!.performKeyEquivalent(with: NSEvent(cgEvent: lEvent)!)

        waitForExpectations(timeout: 5)
    }

    func testKeyEquivalentsAction() throws {
        let expectation = self.expectation(description: "action item key equivalents successfully "
            + "call the action method")
        expectation.expectedFulfillmentCount = 2

        let target = Target(expectation: expectation)
        let ribbon = try Ribbon.loadFromMainBundle(target: target)

        let actionItem = ribbon.item(withIdentifier: .actionItem)
        let actionButton = actionItem!.control as? RibbonPopUpButton

        XCTAssertNotNil(actionButton)

        let pEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(kVK_ANSI_A), keyDown: false)!
        pEvent.flags = [.maskCommand, .maskShift]
        _ = actionButton!.performKeyEquivalent(with: NSEvent(cgEvent: pEvent)!)

        XCTAssertTrue(actionButton!.isHighlighted)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 1))
        XCTAssertFalse(actionButton!.isHighlighted)

        actionItem!.keyEquivalent = "l"
        actionItem!.keyEquivalentModifierMask = [.command]

        let lEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(kVK_ANSI_L), keyDown: false)!
        lEvent.flags = [.maskCommand]
        _ = actionButton!.performKeyEquivalent(with: NSEvent(cgEvent: lEvent)!)

        waitForExpectations(timeout: 5)
    }

    func testKeyEquivalentsSegmentedControl() throws {
        let expectation = self.expectation(description: "segmented item key equivalents "
            + "successfully call the action method")
        expectation.expectedFulfillmentCount = 4

        let target = Target(expectation: expectation)
        let ribbon = try Ribbon.loadFromMainBundle(target: target)

        let segmentedItem = ribbon.item(withIdentifier: .segmentedItem)
        let segmentedControl = segmentedItem!.control as? RibbonSegmentedControl

        XCTAssertNotNil(segmentedControl)

        let pEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(kVK_ANSI_S), keyDown: false)!
        pEvent.flags = [.maskCommand, .maskShift]
        _ = segmentedControl!.performKeyEquivalent(with: NSEvent(cgEvent: pEvent)!)

        segmentedItem!.keyEquivalent = "l"
        segmentedItem!.keyEquivalentModifierMask = [.command]

        let lEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(kVK_ANSI_L), keyDown: false)!
        lEvent.flags = [.maskCommand]
        _ = segmentedControl!.performKeyEquivalent(with: NSEvent(cgEvent: lEvent)!)

        let threeEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(kVK_ANSI_3), keyDown: false)!
        threeEvent.flags = [.maskCommand]
        _ = segmentedControl!.performKeyEquivalent(with: NSEvent(cgEvent: threeEvent)!)

        let fourEvent = CGEvent(keyboardEventSource: nil, virtualKey: CGKeyCode(kVK_ANSI_4), keyDown: false)!
        fourEvent.flags = [.maskCommand]
        _ = segmentedControl!.performKeyEquivalent(with: NSEvent(cgEvent: fourEvent)!)

        waitForExpectations(timeout: 5)
    }
    #endif

    #if canImport(UIKit)
    func testChangeUserInterface() throws {
        let ribbon = try createRibbon(target: nil)

        ribbon.setUserInterfaceStyle(.dark)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.15))

        XCTAssertEqual(ribbon.borderColor(), RibbonColor.darkRibbonBorder)
        ribbon.items.forEach { item in
            // swiftlint:disable next force_cast
            item.controls.map({ $0 as! RibbonButton }).forEach { button in
                XCTAssertEqual(button.backgroundColor, RibbonColor.darkButtonBackground)
                XCTAssertEqual(button.borderColor(), RibbonColor.darkButtonBorder)
                XCTAssertEqual(button.tintColor, RibbonColor.darkButtonTint)
                XCTAssertEqual(button.titleColor(for: .normal), RibbonColor.darkButtonTint)
                XCTAssertEqual(button.titleColor(for: .highlighted), RibbonColor.darkButtonHighlightedTitle)
            }
        }

        ribbon.setUserInterfaceStyle(.light)
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.15))

        XCTAssertEqual(ribbon.borderColor(), RibbonColor.lightRibbonBorder)
        ribbon.items.forEach { item in
            item.controls.map({ $0 as! RibbonButton }).forEach { button in
                XCTAssertEqual(button.backgroundColor, RibbonColor.lightButtonBackground)
                XCTAssertEqual(button.borderColor(), RibbonColor.lightButtonBorder)
                XCTAssertEqual(button.tintColor, RibbonColor.lightButtonTint)
                XCTAssertEqual(button.titleColor(for: .normal), RibbonColor.lightButtonTint)
                XCTAssertEqual(button.titleColor(for: .highlighted), RibbonColor.lightButtonHighlightedTitle)
            }
        }
    }
    #endif

}
