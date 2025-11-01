//
//  extension+UIFont.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/1/25.
//

import UIKit

extension UIFont {

    static func daangnHeading() -> UIFont {
        .systemFont(ofSize: 26, weight: .medium)
    }

    static func daangnBody() -> UIFont {
        .systemFont(ofSize: 17, weight: .regular)
    }

    static func daangnButton() -> UIFont {
        .systemFont(ofSize: 15, weight: .medium)
    }

    static func daangnListTitle() -> UIFont {
        .systemFont(ofSize: 16, weight: .semibold)
    }

    static func daangnListSubtitle() -> UIFont {
        .systemFont(ofSize: 14, weight: .regular)
    }

    static func daangnPrice() -> UIFont {
        .systemFont(ofSize: 16, weight: .bold)
    }
}


