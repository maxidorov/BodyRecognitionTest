//
//  SceneDelegate.swift
//  BodyRecognitionTest
//
//  Created by Maxim V. Sidorov on 11/3/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let mainScene = (scene as? UIWindowScene) else { return }

    let window = UIWindow(windowScene: mainScene)
    window.rootViewController = TestViewController()
    window.makeKeyAndVisible()
    self.window = window
  }
}
