//
//  PDFViewController.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/01/25.
//

import UIKit
import WebKit

final class PDFViewController: UIViewController {

    private let url: URL
    private let displayTitle: String

    private var pdfView: PDFView {
        view as! PDFView
    }

    init(url: URL, title: String? = nil) {
        self.url = url
        self.displayTitle = title ?? "PDF"
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = PDFView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        pdfView.setTitle(displayTitle)
        pdfView.onBackTap = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        pdfView.webView.navigationDelegate = self
        pdfView.webView.allowsBackForwardNavigationGestures = true
        loadPDF()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func loadPDF() {
        pdfView.setLoading(true)
        let request = URLRequest(url: url)
        pdfView.webView.load(request)
    }
}

// MARK: - WKNavigationDelegate

extension PDFViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        pdfView.setLoading(true)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        pdfView.setLoading(false)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        pdfView.setLoading(false)
        presentErrorAlert(message: "PDF를 불러오지 못했습니다.")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        pdfView.setLoading(false)
        presentErrorAlert(message: "PDF를 불러오지 못했습니다.")
    }

    private func presentErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - PDFView

private final class PDFView: UIView {

    // MARK: - Public

    let webView: WKWebView = {
        let view = WKWebView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()

    var onBackTap: (() -> Void)?

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

    private let titleContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemGray6
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .daangnGray900
        return label
    }()

    private let titleDivider: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .daangnGray200
        return view
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        setupLayout()
        backButton.addTarget(self, action: #selector(handleBackTap), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    func setLoading(_ loading: Bool) {
        if loading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    // MARK: - Layout

    private func setupLayout() {
        addSubview(backButton)
        addSubview(titleContainerView)
        titleContainerView.addSubview(titleLabel)
        titleContainerView.addSubview(titleDivider)
        addSubview(webView)
        addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 17),
            backButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -17),

            titleContainerView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 12),
            titleContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: titleContainerView.leadingAnchor, constant: 17),
            titleLabel.trailingAnchor.constraint(equalTo: titleContainerView.trailingAnchor, constant: -17),
            titleLabel.topAnchor.constraint(equalTo: titleContainerView.topAnchor, constant: 16),
            titleLabel.bottomAnchor.constraint(equalTo: titleContainerView.bottomAnchor, constant: -16),

            titleDivider.leadingAnchor.constraint(equalTo: titleContainerView.leadingAnchor),
            titleDivider.trailingAnchor.constraint(equalTo: titleContainerView.trailingAnchor),
            titleDivider.bottomAnchor.constraint(equalTo: titleContainerView.bottomAnchor),
            titleDivider.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),

            webView.topAnchor.constraint(equalTo: titleContainerView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    @objc
    private func handleBackTap() {
        onBackTap?()
    }
}


