//
//  BookDetailViewController.swift
//  DaangnBookSearch
//
//  Moved & updated by Assistant on 10/31/25.
//

import UIKit

final class BookDetailViewController: UIViewController {

    private let viewModel: BookDetailViewModel

    init(viewModel: BookDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = BookDetailView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Book Detail"
    }
}


