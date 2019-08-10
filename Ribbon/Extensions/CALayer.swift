//
//  CALayer.swift
//  Ribbon
//
//  Created by Chris Zielinski on 8/9/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension CALayer {

    // MARK: - Sublayer Retrieval Methods

    func sublayer(named name: String) -> CALayer? {
        return sublayers?.first(where: { $0.name == name })
    }

}
#endif
