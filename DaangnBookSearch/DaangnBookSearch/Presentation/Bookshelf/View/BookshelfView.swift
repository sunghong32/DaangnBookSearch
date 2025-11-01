//
//  BookshelfView.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/1/25.
//

import UIKit

final class BookshelfView: UIView {

    // MARK: - Subviews

    private let headerBackgroundView = GradientBackgroundView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .daangnHeading()
        label.textColor = .daangnGray900
        label.text = "내 책장"
        return label
    }()

    private let countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .daangnListSubtitle()
        label.textColor = .daangnGray600
        label.text = "0권의 책"
        return label
    }()

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.estimatedItemSize = .zero
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 32, right: 0)
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    private let emptyStateStackView: UIStackView = {
        let image = UIImage(named: "EmptyHeart")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .daangnGray200
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
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        return stack
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func setupLayout() {
        headerBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headerBackgroundView)
        addSubview(collectionView)
        addSubview(emptyStateStackView)
        headerBackgroundView.addSubview(titleLabel)
        headerBackgroundView.addSubview(countLabel)

        NSLayoutConstraint.activate([
            headerBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            headerBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 26),
            titleLabel.leadingAnchor.constraint(equalTo: headerBackgroundView.leadingAnchor, constant: 17),

            countLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            countLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            headerBackgroundView.bottomAnchor.constraint(equalTo: countLabel.bottomAnchor, constant: 30),

            collectionView.topAnchor.constraint(equalTo: headerBackgroundView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -17),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),

            emptyStateStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            emptyStateStackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    // MARK: - Update

    func updateBookCount(_ count: Int) {
        countLabel.text = "\(count)권의 책"
    }

    func setEmptyStateVisible(_ isVisible: Bool) {
        emptyStateStackView.isHidden = !isVisible
        collectionView.isHidden = isVisible
    }
}

// MARK: - GradientBackgroundView

private final class GradientBackgroundView: UIView {
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer.colors = [UIColor.daangnBackgroundAccent.cgColor, UIColor.white.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

