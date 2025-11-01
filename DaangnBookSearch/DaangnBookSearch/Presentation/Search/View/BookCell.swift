//
//  BookCell.swift
//  DaangnBookSearch
//
//  Created by Assistant on 10/31/25.
//

import UIKit

final class BookCell: UICollectionViewCell {
    static let identifier = "BookCell"

    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let priceLabel = UILabel()
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
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 8

        thumbnailImageView.contentMode = .scaleAspectFit
        thumbnailImageView.backgroundColor = .tertiarySystemBackground
        thumbnailImageView.layer.cornerRadius = 4

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 2

        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 1

        priceLabel.font = .systemFont(ofSize: 16, weight: .bold)
        priceLabel.textColor = UIColor(red: 1.0, green: 0.44, blue: 0.06, alpha: 1.0)

        [thumbnailImageView, titleLabel, subtitleLabel, priceLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 80),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 120),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
        ])
    }

    func configure(with book: BookSummary) {
        titleLabel.text = book.title
        subtitleLabel.text = book.subtitle
        priceLabel.text = book.price

        thumbnailImageView.image = nil
        imageTask?.cancel()

        guard let url = book.imageURL else { return }
        imageTask = loadImage(from: url)
    }

    private func loadImage(from url: URL) -> Task<Void, Never> {
        return Task { [weak self] in
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard let image = UIImage(data: data) else { return }
                await MainActor.run {
                    self?.thumbnailImageView.image = image
                }
            } catch {
                print("Failed to load image: \(error)")
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        thumbnailImageView.image = nil
    }
}

