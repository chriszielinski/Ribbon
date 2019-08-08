//
//  RibbonConfiguration.swift
//  Ribbon 🎀
//
//  Created by Chris Zielinski on 7/26/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

import Foundation

public struct RibbonConfiguration: Decodable {

    // MARK: - Declarations

    // MARK: Enumerations

    public enum Error: LocalizedError {
        case noConfigurationFile
        case noItems
    }

    // MARK: - Type Methods

    public static func readFromBundle(_ bundle: Bundle,
                                      filename: String = configurationFilename,
                                      delegate: RibbonDelegate? = nil) throws -> RibbonConfiguration {
        guard let url = bundle.url(forResource: filename, withExtension: "json")
            else { throw Error.noConfigurationFile }

        let decoder = JSONDecoder()
        decoder.userInfo[.ribbonDelegate] = delegate
        let configuration = try decoder.decode(RibbonConfiguration.self, from: try Data(contentsOf: url))

        guard !configuration.items.isEmpty
            else { throw Error.noItems }

        return configuration
    }

    // MARK: - Stored Properties

    // MARK: Type

    public static var configurationFilename: String = "ribbon-configuration"

    // MARK: Constant

    public let items: [RibbonItem]
    #if canImport(AppKit)
    public let toolbar: RibbonToolbarConfiguration?
    #endif

}
