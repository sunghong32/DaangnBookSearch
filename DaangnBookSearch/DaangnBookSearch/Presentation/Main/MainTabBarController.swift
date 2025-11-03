//
//  MainTabBarController.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/1/25.
//

import UIKit

final class MainTabBarController: UITabBarController {

    private let searchViewModel: SearchViewModel
    private let bookshelfViewModel: BookshelfViewModel
    private let searchHistoryStore: SearchHistoryStore
    private let detailViewControllerBuilder: (BookSummary) -> UIViewController

    init(
        searchViewModel: SearchViewModel,
        bookshelfViewModel: BookshelfViewModel,
        searchHistoryStore: SearchHistoryStore,
        detailViewControllerBuilder: @escaping (BookSummary) -> UIViewController
    ) {
        self.searchViewModel = searchViewModel
        self.bookshelfViewModel = bookshelfViewModel
        self.searchHistoryStore = searchHistoryStore
        self.detailViewControllerBuilder = detailViewControllerBuilder
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
        let searchController = SearchViewController(
            viewModel: searchViewModel,
            searchHistoryStore: searchHistoryStore,
            detailViewControllerBuilder: detailViewControllerBuilder
        )
        let searchNavigation = UINavigationController(rootViewController: searchController)
        searchNavigation.tabBarItem = UITabBarItem(
            title: "검색",
            image: UIImage(named: "Magnifier20")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "MagnifierOrange")?.withRenderingMode(.alwaysOriginal)
        )

        let bookshelfController = BookshelfViewController(
            viewModel: bookshelfViewModel,
            detailViewControllerBuilder: detailViewControllerBuilder
        )
        let bookshelfNavigation = UINavigationController(rootViewController: bookshelfController)
        bookshelfNavigation.tabBarItem = UITabBarItem(
            title: "내 책장",
            image: UIImage(named: "EmptyHeart")?.withRenderingMode(.alwaysTemplate),
            selectedImage: UIImage(named: "Heart17")?.withRenderingMode(.alwaysOriginal)
        )

        setViewControllers([searchNavigation, bookshelfNavigation], animated: false)
    }
}


