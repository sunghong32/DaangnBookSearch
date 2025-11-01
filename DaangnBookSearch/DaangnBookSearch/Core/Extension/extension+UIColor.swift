//
//  extension+UIColor.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/1/25.
//

import UIKit

extension UIColor {

    // MARK: - Brand Colors

    static let daangnOrange = UIColor(hex: 0xFF6F0F)
    static let daangnGreen = UIColor(hex: 0x00A05B)

    // MARK: - Neutral Palette

    static let daangnGray900 = UIColor(hex: 0x101828)
    static let daangnGray700 = UIColor(hex: 0x364153)
    static let daangnGray600 = UIColor(hex: 0x717182)
    static let daangnGray550 = UIColor(hex: 0x6A7282)
    static let daangnGray500 = UIColor(hex: 0x4A5565)
    static let daangnGray400 = UIColor(hex: 0x99A1AF)
    static let daangnGray200 = UIColor(hex: 0xD1D5DC)

    // MARK: - Accent

    static let daangnBackgroundAccent = UIColor(hex: 0xFFF7ED)

    // MARK: - Initializer

    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(hex & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}


