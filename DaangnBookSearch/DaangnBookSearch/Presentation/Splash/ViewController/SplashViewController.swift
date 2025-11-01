//
//  SplashViewController.swift
//  DaangnBookSearch
//
//  Created by Assistant on 10/31/25.
//

import UIKit

final class SplashViewController: UIViewController {

    private let onFinish: () -> Void

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = SplashView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard self != nil else { return }
            self?.onFinish()
        }
    }
}


