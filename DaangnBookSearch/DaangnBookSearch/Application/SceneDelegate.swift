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
        let rootViewController = UINavigationController(rootViewController: SearchViewController())
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // 앱이 포그라운드에서 백그라운드로 전환될 때 호출됩니다.
        // 필요한 경우 데이터를 저장하거나, 공유 리소스를 해제할 수 있습니다.
    }
}
