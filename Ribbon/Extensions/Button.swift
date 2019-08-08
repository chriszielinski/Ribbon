//
//  Button.swift
//  Ribbon 🎀
//
//  Created by Chris Zielinski on 7/25/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

extension Button {

    // MARK: - Property Setter Shims

    func setAttributedTitle(_ title: NSAttributedString?) {
        #if canImport(UIKit)
        setAttributedTitle(title, for: .normal)

        var highlightedTitle: NSMutableAttributedString?
        if let newTitle = title {
            highlightedTitle = newTitle.mutableCopy() as? NSMutableAttributedString
            newTitle.enumerateAttribute(.foregroundColor,
                                        in: NSRange(location: 0, length: newTitle.length)) { (value, range, _) in
                guard let foregroundColor = value as? UIColor
                    else { return }

                highlightedTitle!.addAttribute(.foregroundColor,
                                               value: foregroundColor.withAlphaComponent(0.6),
                                               range: range)
            }
        }

        setAttributedTitle(highlightedTitle, for: .highlighted)
        #else
        attributedTitle = title ?? NSMutableAttributedString()
        #endif
    }

    func setTitle(_ title: String?) {
        #if canImport(UIKit)
        setTitle(title, for: .normal)
        #else
        self.title = title ?? ""
        #endif
    }

    func setImage(_ image: Image?) {
        #if canImport(UIKit)
        setImage(image, for: .normal)
        #else
        self.image = image
        #endif
    }

    // MARK: - Convenience Methods

    #if canImport(AppKit)
    /// Returns the amount of time (in seconds) the button will pause between sending each action message.
    ///
    /// The default interval is taken from a user's default (60 seconds maximum). If the user hasn’t specified
    /// a default value, interval defaults to 0.075 seconds.
    func actionInterval() -> TimeInterval {
        var delay: Float = 0
        var secondInterval: Float = 0

        getPeriodicDelay(&delay, interval: &secondInterval)

        return TimeInterval(secondInterval)
    }
    #endif

}
