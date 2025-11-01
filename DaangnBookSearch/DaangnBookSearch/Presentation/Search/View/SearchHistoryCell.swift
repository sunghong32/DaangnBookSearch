//
//  SearchHistoryCell.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/1/25.
//

import UIKit

final class SearchHistoryCell: UICollectionViewCell {

    static let identifier = "SearchHistoryCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .daangnBody()
        label.textColor = .daangnGray600
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let backgroundContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.daangnBackgroundAccent
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(backgroundContainer)
        backgroundContainer.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backgroundContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            backgroundContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: backgroundContainer.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: backgroundContainer.bottomAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(equalTo: backgroundContainer.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: backgroundContainer.trailingAnchor, constant: -16)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with text: String) {
        titleLabel.text = text
    }
}


