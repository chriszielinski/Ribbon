//
//  Shims.swift
//  Ribbon 🎀
//
//  Created by Chris Zielinski on 7/18/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public typealias Button = UIButton
public typealias Control = Button
public typealias Font = UIFont
public typealias Image = UIImage
public typealias RibbonShim = UIView
#else
import AppKit

public typealias Button = NSButton
public typealias Control = NSControl
public typealias Font = NSFont
public typealias Image = NSImage
public typealias RibbonShim = NSObject
#endif
