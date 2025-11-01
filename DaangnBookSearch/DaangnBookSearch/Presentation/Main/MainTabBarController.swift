//
//  MainTabBarController.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/1/25.
//

import UIKit

final class MainTabBarController: UITabBarController {

    private let searchViewModel: SearchViewModel

    init(searchViewModel: SearchViewModel) {
        self.searchViewModel = searchViewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBarAppearance()
        setupTabs()
    }

    private func configureTabBarAppearance() {
        tabBar.tintColor = .daangnOrange
        tabBar.unselectedItemTintColor = .daangnGray400
        tabBar.backgroundColor = .white

        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.shadowImage = nil
            appearance.shadowColor = UIColor.daangnGray200.withAlphaComponent(0.5)
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
    }

    private func setupTabs() {
        let searchController = SearchViewController(viewModel: searchViewModel)
        let searchNavigation = UINavigationController(rootViewController: searchController)
        searchNavigation.tabBarItem = UITabBarItem(
            title: "검색",
            image: UIImage(named: "Magnifier20")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "MagnifierOrange")?.withRenderingMode(.alwaysOriginal)
        )

        let bookshelfController = BookshelfViewController()
        let bookshelfNavigation = UINavigationController(rootViewController: bookshelfController)
        bookshelfNavigation.tabBarItem = UITabBarItem(
            title: "내 책장",
            image: UIImage(named: "EmptyHeart")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "EmptyHeart")?.withRenderingMode(.alwaysTemplate)
        )

        setViewControllers([searchNavigation, bookshelfNavigation], animated: false)
    }
}


