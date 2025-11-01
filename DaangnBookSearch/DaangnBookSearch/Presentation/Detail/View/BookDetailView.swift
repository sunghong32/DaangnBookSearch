//
//  BookDetailView.swift
//  DaangnBookSearch
//
//  Created by Assistant on 10/31/25.
//

import UIKit

final class BookDetailView: UIView {

    // MARK: - ViewData

    struct ViewData {
        struct PDFItem {
            let title: String
            let url: URL
        }

        let title: String
        let subtitle: String
        let price: String
        let authors: String
        let publisher: String
        let pages: String
        let year: String
        let description: String
        let imageURL: URL?
        let pdfs: [PDFItem]
        let isFavorited: Bool
    }

    // MARK: - Callbacks

    var onAddToShelfTap: (() -> Void)?
    var onBackButtonTap: (() -> Void)?
    var onPDFSelected: ((URL) -> Void)?

    // MARK: - UI Components

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "BackOrange")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.setTitle("뒤로", for: .normal)
        button.setTitleColor(.daangnOrange, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.tintColor = .daangnOrange
        button.contentHorizontalAlignment = .leading
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        return button
    }()

    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.alwaysBounceVertical = true
        scroll.backgroundColor = .clear
        return scroll
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let headerContainerView = GradientHeaderView()

    private let headerContentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .top
        stack.spacing = 17
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let coverShadowView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.15).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 12
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        view.layer.masksToBounds = false
        return view
    }()

    private let coverImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Document"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 15
        return imageView
    }()

    private let infoStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        label.textColor = .daangnGray900
        label.numberOfLines = 0
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .daangnListSubtitle()
        label.textColor = .daangnGray600
        label.numberOfLines = 0
        return label
    }()

    private let addToShelfButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.daangnOrange.cgColor
        button.setTitle("내 책장에 담기", for: .normal)
        button.setTitleColor(.daangnOrange, for: .normal)
        button.titleLabel?.font = .daangnButton()
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        button.tintColor = .daangnOrange
        button.setImage(UIImage(named: "EmptyHeart")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 4)
        button.semanticContentAttribute = .forceLeftToRight
        button.heightAnchor.constraint(equalToConstant: 46).isActive = true
        return button
    }()

    private let priceCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.daangnGray200.cgColor
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.masksToBounds = false
        return view
    }()

    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 25.5, weight: .medium)
        label.textColor = .daangnOrange
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let infoCardView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.daangnBackgroundAccent
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.04).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 12
        view.layer.shadowOffset = CGSize(width: 0, height: 6)
        return view
    }()

    private let infoRowsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .medium)
        label.textColor = .daangnGray900
        label.text = "책 소개"
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .daangnListSubtitle()
        label.textColor = UIColor(hex: 0x364153)
        label.numberOfLines = 0
        return label
    }()

    private let pdfSectionContainer: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.isHidden = true
        return stack
    }()

    private let pdfTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .medium)
        label.textColor = .daangnGray900
        label.text = "PDF 보기"
        return label
    }()

    private let pdfListStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let loadingOverlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.85)
        view.isHidden = true
        return view
    }()

    private let loadingIndicator = LoadingSpinnerView()

    // MARK: - Private

    private var imageLoadTask: Task<Void, Never>?

    deinit {
        imageLoadTask?.cancel()
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupLayout()
        setupActions()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout Setup

    private func setupLayout() {
        addSubview(backButton)
        addSubview(scrollView)
        addSubview(loadingOverlayView)
        scrollView.addSubview(contentView)
        contentView.addSubview(contentStackView)

        contentStackView.addArrangedSubview(headerContainerView)
        headerContainerView.addSubview(headerContentStack)
        headerContainerView.addSubview(priceCardView)

        contentStackView.addArrangedSubview(infoCardView)
        infoCardView.addSubview(infoRowsStackView)

        contentStackView.addArrangedSubview(descriptionTitleLabel)
        contentStackView.addArrangedSubview(descriptionLabel)
        contentStackView.addArrangedSubview(pdfSectionContainer)
        pdfSectionContainer.addArrangedSubview(pdfTitleLabel)
        pdfSectionContainer.addArrangedSubview(pdfListStackView)

        coverShadowView.addSubview(coverImageView)
        headerContentStack.addArrangedSubview(coverShadowView)
        headerContentStack.addArrangedSubview(infoStackView)

        infoStackView.addArrangedSubview(titleLabel)
        infoStackView.addArrangedSubview(subtitleLabel)
        infoStackView.addArrangedSubview(addToShelfButton)
        infoStackView.setCustomSpacing(20, after: subtitleLabel)

        priceCardView.addSubview(priceLabel)

        loadingOverlayView.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17),
            backButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -17),

            scrollView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            contentStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contentStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),

            coverShadowView.widthAnchor.constraint(equalToConstant: 136),
            coverShadowView.heightAnchor.constraint(equalToConstant: 187),
            coverImageView.topAnchor.constraint(equalTo: coverShadowView.topAnchor),
            coverImageView.leadingAnchor.constraint(equalTo: coverShadowView.leadingAnchor),
            coverImageView.trailingAnchor.constraint(equalTo: coverShadowView.trailingAnchor),
            coverImageView.bottomAnchor.constraint(equalTo: coverShadowView.bottomAnchor),

            headerContentStack.topAnchor.constraint(equalTo: headerContainerView.topAnchor, constant: 26),
            headerContentStack.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 16),
            headerContentStack.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -16),

            priceCardView.topAnchor.constraint(equalTo: headerContentStack.bottomAnchor, constant: 26),
            priceCardView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 16),
            priceCardView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -16),
            priceCardView.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: -24),
            priceCardView.heightAnchor.constraint(equalToConstant: 58),

            priceLabel.centerYAnchor.constraint(equalTo: priceCardView.centerYAnchor),
            priceLabel.leadingAnchor.constraint(equalTo: priceCardView.leadingAnchor, constant: 20),

            infoRowsStackView.topAnchor.constraint(equalTo: infoCardView.topAnchor, constant: 20),
            infoRowsStackView.leadingAnchor.constraint(equalTo: infoCardView.leadingAnchor, constant: 20),
            infoRowsStackView.trailingAnchor.constraint(equalTo: infoCardView.trailingAnchor, constant: -20),
            infoRowsStackView.bottomAnchor.constraint(equalTo: infoCardView.bottomAnchor, constant: -20),

            loadingOverlayView.topAnchor.constraint(equalTo: topAnchor),
            loadingOverlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingOverlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingOverlayView.bottomAnchor.constraint(equalTo: bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: loadingOverlayView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingOverlayView.centerYAnchor),
            loadingIndicator.widthAnchor.constraint(equalToConstant: 42),
            loadingIndicator.heightAnchor.constraint(equalToConstant: 42)
        ])

        headerContainerView.heightAnchor.constraint(equalToConstant: 342).isActive = true
        bringSubviewToFront(backButton)
    }

    private func setupActions() {
        addToShelfButton.addTarget(self, action: #selector(handleAddToShelfTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(handleBackButtonTapped), for: .touchUpInside)
    }

    // MARK: - Configuration

    func configure(with data: ViewData) {
        titleLabel.text = data.title
        subtitleLabel.text = data.subtitle
        subtitleLabel.isHidden = data.subtitle.isEmpty
        priceLabel.text = data.price
        updateInfoRows(with: data)
        let trimmedDescription = data.description.trimmingCharacters(in: .whitespacesAndNewlines)
        descriptionLabel.text = trimmedDescription
        descriptionLabel.isHidden = trimmedDescription.isEmpty
        descriptionTitleLabel.isHidden = trimmedDescription.isEmpty
        updatePDFs(data.pdfs)
        updateFavoriteState(isFavorite: data.isFavorited)
        loadCoverImage(from: data.imageURL)
    }

    func setLoading(_ isLoading: Bool) {
        loadingOverlayView.isHidden = !isLoading
        if isLoading {
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
    }

    func updateFavoriteState(isFavorite: Bool) {
        addToShelfButton.layer.borderColor = UIColor.daangnOrange.cgColor
        if isFavorite {
            addToShelfButton.backgroundColor = .daangnOrange
            addToShelfButton.setTitleColor(.white, for: .normal)
            addToShelfButton.tintColor = .white
            addToShelfButton.setImage(UIImage(named: "HeartWhite")?.withRenderingMode(.alwaysOriginal), for: .normal)
            addToShelfButton.setTitle("내 책장에 담김", for: .normal)
        } else {
            addToShelfButton.backgroundColor = .clear
            addToShelfButton.setTitleColor(.daangnOrange, for: .normal)
            addToShelfButton.tintColor = .daangnOrange
            addToShelfButton.setImage(UIImage(named: "EmptyHeart")?.withRenderingMode(.alwaysTemplate), for: .normal)
            addToShelfButton.setTitle("내 책장에 담기", for: .normal)
        }
    }

    // MARK: - Private Helpers

    private func updateInfoRows(with data: ViewData) {
        infoRowsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let items: [(String, String)] = [
            ("저자", data.authors),
            ("출판사", data.publisher),
            ("출판년도", data.year),
            ("페이지", data.pages)
        ]

        items.forEach { title, value in
            guard value.isEmpty == false else { return }
            let container = makeInfoRow(title: title, value: value)
            infoRowsStackView.addArrangedSubview(container)
        }

        infoCardView.isHidden = infoRowsStackView.arrangedSubviews.isEmpty
    }

    private func makeInfoRow(title: String, value: String) -> UIView {
        let container = UIStackView()
        container.axis = .horizontal
        container.spacing = 8
        container.alignment = .leading

        let titleLabel = UILabel()
        titleLabel.font = .daangnListSubtitle()
        titleLabel.textColor = .daangnGray600
        titleLabel.text = title
        titleLabel.widthAnchor.constraint(equalToConstant: 84).isActive = true

        let valueLabel = UILabel()
        valueLabel.font = .daangnListSubtitle()
        valueLabel.textColor = .daangnGray900
        valueLabel.text = value
        valueLabel.numberOfLines = 0

        container.addArrangedSubview(titleLabel)
        container.addArrangedSubview(valueLabel)
        return container
    }

    private func updatePDFs(_ pdfs: [ViewData.PDFItem]) {
        pdfListStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard !pdfs.isEmpty else {
            pdfSectionContainer.isHidden = true
            return
        }

        pdfSectionContainer.isHidden = false
        pdfs.forEach { item in
            let button = makePDFButton(title: item.title, url: item.url)
            pdfListStackView.addArrangedSubview(button)
        }
    }

    private func makePDFButton(title: String, url: URL) -> UIView {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.daangnGray200.cgColor
        button.contentEdgeInsets = .zero
        button.contentHorizontalAlignment = .left

        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = UIColor.daangnOrange.withAlphaComponent(0.12)
        iconContainer.layer.cornerRadius = 12

        let iconImage = UIImageView(image: UIImage(named: "Document")?.withRenderingMode(.alwaysTemplate))
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        iconImage.contentMode = .scaleAspectFit
        iconImage.tintColor = .daangnOrange

        iconContainer.addSubview(iconImage)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .daangnListSubtitle()
        titleLabel.textColor = .daangnGray900
        titleLabel.text = title
        titleLabel.numberOfLines = 1

        let chevron = UIImageView(image: UIImage(named: "RightChevron")?.withRenderingMode(.alwaysTemplate))
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.tintColor = .daangnGray400

        button.addSubview(iconContainer)
        button.addSubview(titleLabel)
        button.addSubview(chevron)

        NSLayoutConstraint.activate([
            iconContainer.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
            iconContainer.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 40),
            iconContainer.heightAnchor.constraint(equalToConstant: 40),

            iconImage.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImage.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImage.widthAnchor.constraint(equalToConstant: 20),
            iconImage.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevron.leadingAnchor, constant: -12),

            chevron.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),
            chevron.heightAnchor.constraint(equalToConstant: 12),

            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 64)
        ])

        button.addAction(UIAction { [weak self] _ in
            self?.onPDFSelected?(url)
        }, for: .touchUpInside)

        return button
    }

    private func loadCoverImage(from url: URL?) {
        imageLoadTask?.cancel()
        coverImageView.image = UIImage(named: "Document")
        guard let url else { return }
        imageLoadTask = ImageLoader.shared.loadImageTask(from: url) { [weak self] image in
            self?.coverImageView.image = image ?? UIImage(named: "Document")
        }
    }

    @objc
    private func handleAddToShelfTapped() {
        onAddToShelfTap?()
    }

    @objc
    private func handleBackButtonTapped() {
        onBackButtonTap?()
    }
}

// MARK: - GradientHeaderView

private final class GradientHeaderView: UIView {

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

// MARK: - ImageLoader Convenience

private extension ImageLoader {
    func loadImageTask(from url: URL, completion: @escaping (UIImage?) -> Void) -> Task<Void, Never> {
        Task {
            do {
                let image = try await loadImage(from: url)
                await MainActor.run {
                    completion(image)
                }
            } catch {
                await MainActor.run {
                    completion(nil)
                }
            }
        }
    }
}

