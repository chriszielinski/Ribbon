//
//  String.swift
//  Demo (iOS)
//
//  Created by Chris Zielinski on 7/21/19.
//  Copyright © 2019 Big Z Labs. All rights reserved.
//

import UIKit

// MARK: - Ribbon Item Identifiers

extension String {

    // MARK: - Stored Properties

    // MARK: Type

    static let actionItem: String = "action-item"
    static let firstActionSubitem: String = "first-action-subitem"
    static let secondActionSubitem: String = "second-action-subitem"
    static let pushItem: String = "push-item"
    static let segmentedItem: String = "Segmented Item"
    static let firstSegmentedSubitem: String = "first-segmented-subitem"
    static let secondSegmentedSubitem: String = "second-segmented-subitem"

}

// MARK: - Drawing Methods

extension String {

    /// https://gist.github.com/tad-iizuka/58d22bed8aecfe51360b7faea4a34bcb#file-emojitoimage
    func emojiToImage(size: CGFloat) -> UIImage {
        let outputImageSize = CGSize(width: size, height: size)
        let baseSize = self.boundingRect(with: CGSize(width: 2048, height: 2048),
                                         options: .usesLineFragmentOrigin,
                                         attributes: [.font: UIFont.systemFont(ofSize: size / 2)],
                                         context: nil).size
        let fontSize = outputImageSize.width / max(baseSize.width, baseSize.height) * (outputImageSize.width / 2)
        let font = UIFont.systemFont(ofSize: fontSize)
        let textSize = self.boundingRect(with: CGSize(width: outputImageSize.width, height: outputImageSize.height),
                                         options: .usesLineFragmentOrigin,
                                         attributes: [.font: font],
                                         context: nil).size

        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.lineBreakMode = .byClipping

        let attr: [NSAttributedString.Key: Any] = [
            .font: font,
            .paragraphStyle: style,
            .backgroundColor: UIColor.clear
        ]

        UIGraphicsBeginImageContextWithOptions(outputImageSize, false, 0)
        self.draw(in: CGRect(x: (size - textSize.width) / 2,
                             y: (size - textSize.height) / 2,
                             width: textSize.width,
                             height: textSize.height),
                  withAttributes: attr)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image
    }

}
