//
//  UIApplication.swift
//  Ribbon
//
//  Created by Chris Zielinski on 2/24/20.
//  Copyright © 2020 Big Z Labs. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension UIApplication {

    var keyboardWindow: UIWindow? {
        return windows.first { String(describing: type(of: $0)).contains("Keyboard") }
    }

}
#endif
