//
//  SearchViewController.swift
//  DaangnBookSearch
//
//  Created by 민성홍 on 10/30/25.
//

import UIKit

final class SearchViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search Books"
        view.backgroundColor = .systemBackground

        // 임시 UI (빌드 확인용)
        let label = UILabel()
        label.text = "Search Screen"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
