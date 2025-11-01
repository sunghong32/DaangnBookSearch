//
//  BookshelfView.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/1/25.
//

import UIKit

final class BookshelfView: UIView {

    private let placeholderStackView: UIStackView = {
        let image = UIImage(named: "EmptyHeart")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .daangnGray400
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 56),
            imageView.heightAnchor.constraint(equalToConstant: 56)
        ])

        let titleLabel = UILabel()
        titleLabel.text = "즐겨찾기한 책이 없습니다"
        titleLabel.font = .daangnBody()
        titleLabel.textColor = .daangnGray400
        titleLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [imageView, titleLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(placeholderStackView)

        NSLayoutConstraint.activate([
            placeholderStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


