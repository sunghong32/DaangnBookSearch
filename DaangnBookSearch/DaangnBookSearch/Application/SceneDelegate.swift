//
//  SceneDelegate.swift
//  DaangnBookSearch
//
//  Created by 민성홍 on 10/27/25.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        
        let splash = SplashViewController { [weak window] in
            guard let window else { return }
            
            // MARK: - Network & Repository 설정
            let provider = NetworkProvider()
            let bookNetworkRepository = BookNetworkRepository(provider: provider)
            
            // MARK: - UseCase 설정
            let searchBooksUseCase = SearchBooksUseCase(bookRepository: bookNetworkRepository)
            let fetchBookDetailUseCase = FetchBookDetailUseCase(bookRepository: bookNetworkRepository)
            
            // MARK: - BookshelfStore 설정 (싱글톤 없이 인스턴스 생성)
            // 여러 ViewModel에서 공유할 단일 Store 인스턴스 생성
            let bookshelfStore = BookshelfStore()
            
            // MARK: - SearchHistoryStore 설정
            let searchHistoryStore = SearchHistoryStore()
            
            // MARK: - BookshelfRepository 설정
            // 영구 저장을 위한 Repository 인스턴스 생성
            let bookshelfRepository = BookshelfUserDefaultsRepository()
            
            // MARK: - Bookshelf 관련 UseCase 설정
            let loadBookshelfUseCase = LoadBookshelfUseCase(
                bookshelfStore: bookshelfStore,
                repository: bookshelfRepository
            )
            
            let toggleBookshelfUseCase = ToggleBookshelfUseCase(
                bookshelfStore: bookshelfStore,
                repository: bookshelfRepository
            )
            
            // MARK: - 저장된 즐겨찾기 불러오기
            // 앱 시작 시 저장된 즐겨찾기를 불러와 Store에 반영
            Task {
                try? await loadBookshelfUseCase.execute()
            }
            
            // MARK: - ViewModel 설정
            // 각 ViewModel에 동일한 Store 인스턴스 주입
            // ViewModel 간 의존성 없이 동일 데이터 공유
            let searchViewModel = SearchViewModel(
                searchBooksUseCase: searchBooksUseCase,
                toggleBookshelfUseCase: toggleBookshelfUseCase,
                bookshelfStore: bookshelfStore
            )
            
            let bookshelfViewModel = BookshelfViewModel(
                bookshelfStore: bookshelfStore,
                toggleBookshelfUseCase: toggleBookshelfUseCase
            )
            
            // MARK: - Detail 화면 빌더
            let detailBuilder: (BookSummary) -> UIViewController = { summary in
                let detailViewModel = BookDetailViewModel(
                    fetchBookDetailUseCase: fetchBookDetailUseCase
                )
                detailViewModel.send(.setISBN(summary.isbn13))
                return BookDetailViewController(
                    viewModel: detailViewModel,
                    summary: summary,
                    bookshelfStore: bookshelfStore,
                    toggleBookshelfUseCase: toggleBookshelfUseCase
                )
            }
            
            // MARK: - MainTabBar 설정
            let mainTabBar = MainTabBarController(
                searchViewModel: searchViewModel,
                bookshelfViewModel: bookshelfViewModel,
                searchHistoryStore: searchHistoryStore,
                detailViewControllerBuilder: detailBuilder
            )
            window.rootViewController = mainTabBar
            window.makeKeyAndVisible()
        }

        window.rootViewController = splash
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // 앱이 포그라운드에서 백그라운드로 전환될 때 호출됨
        // 필요 시 데이터 저장 또는 공유 리소스 정리
    }
}
