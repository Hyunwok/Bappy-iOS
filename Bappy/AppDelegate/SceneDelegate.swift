//
//  SceneDelegate.swift
//  Bappy
//
//  Created by 정동천 on 2022/05/10.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .white
        window?.tintColor = UIColor(red: 134.0/255.0, green: 134.0/255.0, blue: 134.0/255.0, alpha: 1.0)
        
//        let viewModel = RegisterViewModel()
//        let rootViewController = RegisterViewController(viewModel: viewModel)
//        let rootViewController = RegisterViewController()
        let rootViewController = BappyTabBarController()
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
}

