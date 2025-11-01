//
//  SearchView.swift
//  DaangnBookSearch
//
//  Created by Assistant on 10/31/25.
//

import UIKit

final class SearchView: UIView {

    // MARK: - UI Components

    private let headerContainerView: GradientBackgroundView = {
        let view = GradientBackgroundView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 0
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "책 검색"
        label.font = .daangnHeading()
        label.textColor = .daangnGray900
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let searchContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.cornerRadius = 14.5
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.daangnGray200.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let queryTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "책 제목, 저자명으로 검색"
        textField.borderStyle = .none
        textField.font = .daangnBody()
        textField.textColor = .daangnGray900
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.returnKeyType = .search
        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no

        let iconImage = UIImage(named: "Magnifier20")?.withRenderingMode(.alwaysTemplate)
        let icon = UIImageView(image: iconImage)
        icon.tintColor = .daangnGray600
        icon.contentMode = .scaleAspectFit
        icon.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 50))
        icon.center = CGPoint(x: paddingView.bounds.midX, y: paddingView.bounds.midY)
        paddingView.addSubview(icon)
        textField.leftView = paddingView
        textField.leftViewMode = .always

        return textField
    }()

    let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("검색", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .daangnButton()
        button.backgroundColor = .daangnOrange
        button.layer.cornerRadius = 14.5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let initialPlaceholderStackView: UIStackView = {
        let image = UIImage(named: "Magnifier48")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .daangnGray400
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 48),
            imageView.heightAnchor.constraint(equalToConstant: 48)
        ])

        let label = UILabel()
        label.text = "책을 검색해보세요"
        label.font = .daangnBody()
        label.textColor = .daangnGray400
        label.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let emptyResultLabel: UILabel = {
        let label = UILabel()
        label.text = "검색 결과가 없습니다."
        label.font = .daangnBody()
        label.textColor = .daangnGray500
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.keyboardDismissMode = .onDrag
        return cv
    }()
    
    let historyDropdownView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.daangnGray200.cgColor
        view.layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 10
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.masksToBounds = false
        view.isHidden = true
        return view
    }()

    private let historyHeaderIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "clock"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .daangnGray400
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 16),
            imageView.heightAnchor.constraint(equalToConstant: 16)
        ])
        return imageView
    }()

    private let historyHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "최근 검색"
        label.font = .daangnListSubtitle()
        label.textColor = .daangnGray600
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let historyClearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("지우기", for: .normal)
        button.setTitleColor(.daangnGray400, for: .normal)
        button.titleLabel?.font = .daangnListSubtitle()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()

    let historyDropdownCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        return cv
    }()

    private var historyDropdownHeightConstraint: NSLayoutConstraint?
    private let historyHeaderDivider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .daangnGray200
        return view
    }()

    private let loadingOverlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.85)
        view.isHidden = true
        return view
    }()

    private let loadingSpinner: LoadingSpinnerView = {
        let spinner = LoadingSpinnerView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.widthAnchor.constraint(equalToConstant: 42),
            spinner.heightAnchor.constraint(equalToConstant: 42)
        ])
        return spinner
    }()

    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "검색 중..."
        label.font = .daangnBody()
        label.textColor = .daangnGray550
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var loadingStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [loadingSpinner, loadingLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupLayout()
        showInitialPlaceholder()
        setCollectionViewVisible(false)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    private func setupLayout() {
        addSubview(headerContainerView)
        addSubview(collectionView)
        addSubview(historyDropdownView)
        addSubview(initialPlaceholderStackView)
        addSubview(emptyResultLabel)
        addSubview(loadingOverlayView)
        loadingOverlayView.addSubview(loadingStackView)

        headerContainerView.addSubview(titleLabel)
        headerContainerView.addSubview(searchContainerView)
        headerContainerView.addSubview(searchButton)
        searchContainerView.addSubview(queryTextField)

        let historyHeaderContainer = UIView()
        historyHeaderContainer.translatesAutoresizingMaskIntoConstraints = false
        historyDropdownView.addSubview(historyHeaderContainer)
        historyHeaderContainer.addSubview(historyHeaderIconView)
        historyHeaderContainer.addSubview(historyHeaderLabel)
        historyHeaderContainer.addSubview(historyClearButton)
        historyDropdownView.addSubview(historyHeaderDivider)
        historyDropdownView.addSubview(historyDropdownCollectionView)

        NSLayoutConstraint.activate([
            headerContainerView.topAnchor.constraint(equalTo: topAnchor),
            headerContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 26),
            titleLabel.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 17),

            searchButton.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -17),
            searchButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            searchButton.widthAnchor.constraint(equalToConstant: 77),
            searchButton.heightAnchor.constraint(equalToConstant: 51),

            searchContainerView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 17),
            searchContainerView.trailingAnchor.constraint(equalTo: searchButton.leadingAnchor, constant: -12),
            searchContainerView.centerYAnchor.constraint(equalTo: searchButton.centerYAnchor),
            searchContainerView.heightAnchor.constraint(equalTo: searchButton.heightAnchor),

            queryTextField.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor),
            queryTextField.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor, constant: -12),
            queryTextField.topAnchor.constraint(equalTo: searchContainerView.topAnchor),
            queryTextField.bottomAnchor.constraint(equalTo: searchContainerView.bottomAnchor),

            headerContainerView.bottomAnchor.constraint(equalTo: searchButton.bottomAnchor, constant: 26),

            historyDropdownView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor, constant: 8),
            historyDropdownView.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor),
            historyDropdownView.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor),

            historyHeaderContainer.topAnchor.constraint(equalTo: historyDropdownView.topAnchor, constant: 12),
            historyHeaderContainer.leadingAnchor.constraint(equalTo: historyDropdownView.leadingAnchor, constant: 16),
            historyHeaderContainer.trailingAnchor.constraint(equalTo: historyDropdownView.trailingAnchor, constant: -16),
            historyHeaderContainer.heightAnchor.constraint(equalToConstant: 22),

            historyHeaderIconView.leadingAnchor.constraint(equalTo: historyHeaderContainer.leadingAnchor),
            historyHeaderIconView.centerYAnchor.constraint(equalTo: historyHeaderContainer.centerYAnchor),

            historyHeaderLabel.leadingAnchor.constraint(equalTo: historyHeaderIconView.trailingAnchor, constant: 8),
            historyHeaderLabel.centerYAnchor.constraint(equalTo: historyHeaderContainer.centerYAnchor),

            historyClearButton.centerYAnchor.constraint(equalTo: historyHeaderContainer.centerYAnchor),
            historyClearButton.trailingAnchor.constraint(equalTo: historyHeaderContainer.trailingAnchor),

            historyHeaderDivider.topAnchor.constraint(equalTo: historyHeaderContainer.bottomAnchor, constant: 12),
            historyHeaderDivider.leadingAnchor.constraint(equalTo: historyDropdownView.leadingAnchor, constant: 16),
            historyHeaderDivider.trailingAnchor.constraint(equalTo: historyDropdownView.trailingAnchor, constant: -16),
            historyHeaderDivider.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),

            historyDropdownCollectionView.topAnchor.constraint(equalTo: historyHeaderDivider.bottomAnchor, constant: 12),
            historyDropdownCollectionView.leadingAnchor.constraint(equalTo: historyDropdownView.leadingAnchor),
            historyDropdownCollectionView.trailingAnchor.constraint(equalTo: historyDropdownView.trailingAnchor),
            historyDropdownCollectionView.bottomAnchor.constraint(equalTo: historyDropdownView.bottomAnchor, constant: -12),

            collectionView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),

            initialPlaceholderStackView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            initialPlaceholderStackView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),

            emptyResultLabel.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            emptyResultLabel.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),

            loadingOverlayView.topAnchor.constraint(equalTo: topAnchor),
            loadingOverlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            loadingOverlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            loadingOverlayView.bottomAnchor.constraint(equalTo: bottomAnchor),

            loadingStackView.centerXAnchor.constraint(equalTo: loadingOverlayView.centerXAnchor),
            loadingStackView.centerYAnchor.constraint(equalTo: loadingOverlayView.centerYAnchor)
        ])

        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
        historyDropdownHeightConstraint = historyDropdownView.heightAnchor.constraint(equalToConstant: 0)
        historyDropdownHeightConstraint?.isActive = true
        bringSubviewToFront(historyDropdownView)
    }

    // MARK: - Helpers

    func showInitialPlaceholder() {
        initialPlaceholderStackView.isHidden = false
        emptyResultLabel.isHidden = true
    }

    func showEmptyResultPlaceholder() {
        initialPlaceholderStackView.isHidden = true
        emptyResultLabel.isHidden = false
    }

    func hidePlaceholders() {
        initialPlaceholderStackView.isHidden = true
        emptyResultLabel.isHidden = true
    }

    func setCollectionViewVisible(_ visible: Bool) {
        collectionView.isHidden = !visible
    }

    func setLoadingOverlayVisible(_ visible: Bool) {
        loadingOverlayView.isHidden = !visible
        if visible {
            loadingSpinner.startAnimating()
        } else {
            loadingSpinner.stopAnimating()
        }
    }

    func updateQueryText(_ text: String) {
        guard !queryTextField.isFirstResponder else { return }
        if queryTextField.text != text {
            queryTextField.text = text
        }
    }

    func setHistoryDropdownVisible(_ visible: Bool) {
        historyDropdownView.isHidden = !visible
    }

    func updateHistoryDropdownHeight(itemCount: Int) {
        let headerHeight: CGFloat = 46
        let rowHeight: CGFloat = 51
        let visibleRows = min(max(itemCount, 0), 5)
        let totalHeight = itemCount == 0 ? 0 : headerHeight + CGFloat(visibleRows) * rowHeight + 12
        historyDropdownHeightConstraint?.constant = totalHeight
        historyDropdownCollectionView.isScrollEnabled = itemCount > 5
        historyClearButton.isHidden = itemCount == 0
    }
}

// MARK: - GradientBackgroundView

private final class GradientBackgroundView: UIView {
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        gradientLayer.colors = [UIColor.daangnBackgroundAccent.cgColor, UIColor.white.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}

// MARK: - UIColor+Hex

