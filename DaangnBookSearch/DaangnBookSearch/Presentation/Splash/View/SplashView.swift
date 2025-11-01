//
//  SplashView.swift
//  DaangnBookSearch
//
//  Created by Assistant on 10/31/25.
//

import UIKit

final class SplashView: UIView {

    private let logoImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "DaangnSymbol"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "당근책방"
        label.textColor = .daangnOrange
        label.font = .daangnSplashTitle()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        addSubview(logoImageView)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            logoImageView.widthAnchor.constraint(equalToConstant: 136),
            logoImageView.heightAnchor.constraint(equalToConstant: 136),

            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


