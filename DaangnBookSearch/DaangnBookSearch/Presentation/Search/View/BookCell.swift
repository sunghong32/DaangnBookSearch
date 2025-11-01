//
//  BookCell.swift
//  DaangnBookSearch
//
//  Created by Assistant on 10/31/25.
//

import UIKit

final class BookCell: UICollectionViewCell {
    static let identifier = "BookCell"

    private let cardView = UIView()
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let priceLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    private var imageTask: Task<Void, Never>?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCell() {
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = false

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 17
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = UIColor.daangnGray200.cgColor
        cardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cardView.layer.shadowRadius = 3
        cardView.layer.masksToBounds = false
        contentView.addSubview(cardView)

        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.backgroundColor = UIColor.daangnGray200.withAlphaComponent(0.3)
        thumbnailImageView.layer.cornerRadius = 10.5
        thumbnailImageView.clipsToBounds = true

        titleLabel.font = .daangnListTitle()
        titleLabel.textColor = .daangnGray900
        titleLabel.numberOfLines = 2

        subtitleLabel.font = .daangnListSubtitle()
        subtitleLabel.textColor = .daangnGray600
        subtitleLabel.numberOfLines = 2

        priceLabel.font = .daangnPrice()
        priceLabel.textColor = .daangnOrange

        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        favoriteButton.setImage(UIImage(named: "EmptyHeart")?.withRenderingMode(.alwaysTemplate), for: .normal)
        favoriteButton.tintColor = .daangnGray400
        favoriteButton.isUserInteractionEnabled = false

        [thumbnailImageView, titleLabel, subtitleLabel, priceLabel, favoriteButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            thumbnailImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            thumbnailImageView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 85),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 119),

            favoriteButton.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            favoriteButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            favoriteButton.widthAnchor.constraint(equalToConstant: 24),
            favoriteButton.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 17),
            titleLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            priceLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18),
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
        ])
    }

    func configure(with book: BookSummary, isFavorite: Bool = false) {
        titleLabel.text = book.title
        subtitleLabel.text = book.subtitle
        subtitleLabel.isHidden = book.subtitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        priceLabel.text = book.price

        let heartImage = UIImage(named: "EmptyHeart")?.withRenderingMode(.alwaysTemplate)
        favoriteButton.setImage(heartImage, for: .normal)
        favoriteButton.tintColor = isFavorite ? .daangnOrange : .daangnGray400

        thumbnailImageView.image = nil
        imageTask?.cancel()

        guard let url = book.imageURL else { return }
        imageTask = loadImage(from: url)
    }

    private func loadImage(from url: URL) -> Task<Void, Never> {
        Task { [weak self] in
            do {
                let image = try await ImageLoader.shared.loadImage(from: url)
                await MainActor.run {
                    self?.thumbnailImageView.image = image
                }
            } catch {
                #if DEBUG
                print("Failed to load image: \(error)")
                #endif
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        thumbnailImageView.image = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cardView.layer.shadowPath = UIBezierPath(roundedRect: cardView.bounds, cornerRadius: cardView.layer.cornerRadius).cgPath
    }
}

