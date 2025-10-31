//
//  BookDetailViewController.swift
//  DaangnBookSearch
//
//  Created by 민성홍 on 10/27/25.
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

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Book Detail"
        view.backgroundColor = .systemBackground

        // 임시 UI (빌드 확인용)
        let label = UILabel()
        label.text = "Book Detail Screen"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
