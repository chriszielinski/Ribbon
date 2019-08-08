//
//  RibbonToolbarConfiguration.swift
//  Ribbon 🎀
//
//  Created by Chris Zielinski on 7/26/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

#if canImport(AppKit)
import AppKit

public struct RibbonToolbarConfiguration: Codable {

    // MARK: - Declarations

    // MARK: Enumerations

    public enum KeyEquivalentModifier: String, Codable, CaseIterable {
        case capsLock
        case shift
        case control
        case option
        case command
        case numericPad
        case help
        case function

        public var bridge: NSEvent.ModifierFlags {
            switch self {
            case .capsLock:
                return .capsLock
            case .shift:
                return .shift
            case .control:
                return .control
            case .option:
                return .option
            case .command:
                return .command
            case .numericPad:
                return .numericPad
            case .help:
                return .help
            case .function:
                return .function
            }
        }
    }

    public enum DisplayMode: String, Codable {
        case `default`
        case iconAndLabel
        case iconOnly
        case labelOnly

        public var bridge: NSToolbar.DisplayMode {
            switch self {
            case .iconAndLabel:
                return .iconAndLabel
            case .iconOnly:
                return .iconOnly
            case .labelOnly:
                return .labelOnly
            case .default:
                return .default
            }
        }
    }

    public enum SizeMode: String, Codable {
        case `default`
        case regular
        case small

        public var bridge: NSToolbar.SizeMode {
            switch self {
            case .regular:
                return .regular
            case .small:
                return .small
            case .default:
                return .default
            }
        }
    }

    // MARK: - Stored Properties

    // MARK: Constant

    let allowsExtensionItems: Bool?
    let allowsUserCustomization: Bool?
    let displayMode: DisplayMode?
    let identifier: NSToolbar.Identifier?
    let isVisible: Bool?
    let sizeMode: SizeMode?
    let showsBaselineSeparator: Bool?
    let defaultItems: [String]?

}
#endif
