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

    private let emptyStateStackView: UIStackView = {
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
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.keyboardDismissMode = .onDrag
        return cv
    }()

    // MARK: - init

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
        addSubview(headerContainerView)
        addSubview(collectionView)
        addSubview(emptyStateStackView)

        headerContainerView.addSubview(titleLabel)
        headerContainerView.addSubview(searchContainerView)
        headerContainerView.addSubview(searchButton)
        searchContainerView.addSubview(queryTextField)

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

            collectionView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),

            emptyStateStackView.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyStateStackView.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])

        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
    }

    // MARK: - Helpers

    func updateEmptyState(isHidden: Bool) {
        emptyStateStackView.isHidden = isHidden
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

