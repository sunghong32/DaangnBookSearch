//
//  BookshelfBookCell.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/02/25.
//

import UIKit

final class BookshelfBookCell: UICollectionViewCell {
    static let identifier = "BookshelfBookCell"

    private let cardContainerView = UIView()
    private let coverImageView = UIImageView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    private var imageTask: Task<Void, Never>?

    var onFavoriteTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false

        cardContainerView.translatesAutoresizingMaskIntoConstraints = false
        cardContainerView.backgroundColor = .white
        cardContainerView.layer.cornerRadius = 20
        cardContainerView.layer.borderWidth = 1
        cardContainerView.layer.borderColor = UIColor.daangnGray200.cgColor
        cardContainerView.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        cardContainerView.layer.shadowOpacity = 1
        cardContainerView.layer.shadowRadius = 10
        cardContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.addSubview(cardContainerView)

        coverImageView.translatesAutoresizingMaskIntoConstraints = false
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.backgroundColor = UIColor.daangnGray200.withAlphaComponent(0.15)
        coverImageView.layer.cornerRadius = 16
        coverImageView.clipsToBounds = true

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .daangnListTitle()
        titleLabel.textColor = .daangnGray900
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail

        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = .daangnPrice()
        priceLabel.textColor = .daangnOrange
        priceLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.setImage(UIImage(named: "Heart18")?.withRenderingMode(.alwaysTemplate), for: .normal)
        favoriteButton.tintColor = .daangnOrange
        favoriteButton.backgroundColor = .white
        favoriteButton.layer.cornerRadius = 14
        favoriteButton.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        favoriteButton.layer.shadowOpacity = 1
        favoriteButton.layer.shadowRadius = 6
        favoriteButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        favoriteButton.addTarget(self, action: #selector(handleFavoriteTap), for: .touchUpInside)

        [coverImageView, titleLabel, priceLabel, favoriteButton].forEach { cardContainerView.addSubview($0) }

        NSLayoutConstraint.activate([
            cardContainerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            coverImageView.topAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: 14),
            coverImageView.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 14),
            coverImageView.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -14),
            coverImageView.heightAnchor.constraint(equalToConstant: 140),

            favoriteButton.widthAnchor.constraint(equalToConstant: 28),
            favoriteButton.heightAnchor.constraint(equalToConstant: 28),
            favoriteButton.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -18),
            favoriteButton.topAnchor.constraint(equalTo: cardContainerView.topAnchor, constant: 14),

            titleLabel.topAnchor.constraint(equalTo: coverImageView.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: cardContainerView.leadingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: cardContainerView.trailingAnchor, constant: -14),

            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: cardContainerView.bottomAnchor, constant: -14)
        ])
    }

    func configure(with book: BookSummary) {
        titleLabel.text = book.title
        priceLabel.text = book.price

        coverImageView.image = UIImage(named: "Document")
        imageTask?.cancel()
        if let url = book.imageURL {
            imageTask = loadImage(from: url)
        }
    }

    private func loadImage(from url: URL) -> Task<Void, Never> {
        Task { [weak self] in
            do {
                let image = try await ImageLoader.shared.loadImage(from: url)
                await MainActor.run {
                    self?.coverImageView.image = image
                }
            } catch {
                #if DEBUG
                print("Failed to load bookshelf image: \(error)")
                #endif
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        coverImageView.image = nil
        onFavoriteTap = nil
        favoriteButton.tintColor = .daangnOrange
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cardContainerView.layer.shadowPath = UIBezierPath(roundedRect: cardContainerView.bounds, cornerRadius: cardContainerView.layer.cornerRadius).cgPath
    }

    @objc
    private func handleFavoriteTap() {
        onFavoriteTap?()
    }
}


