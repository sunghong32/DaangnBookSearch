//
//  BookshelfViewController.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/1/25.
//

import UIKit

final class BookshelfViewController: UIViewController {

    override func loadView() {
        view = BookshelfView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "내 책장"
        view.backgroundColor = .systemBackground
    }
}


