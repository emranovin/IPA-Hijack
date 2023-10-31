//
//  SceneDelegate.swift
//
//  Created by Emran Novin on 9/9/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var deeplinkCoordinator: DeeplinkCoordinatorProtocol?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let plistDeeplinkHandler = PlistDeeplinkHandler()
        let testDeepLinkHandler = TestDeeplinkHandler(window?.rootViewController)
        
        deeplinkCoordinator = DeeplinkCoordinator(handlers: [plistDeeplinkHandler, testDeepLinkHandler])
        
        if let vc = window?.rootViewController as? MainViewController {
            vc.deeplinkCoordinator = deeplinkCoordinator
            plistDeeplinkHandler.delegate = vc
        }
    }

}

extension SceneDelegate {
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let firstUrl = URLContexts.first?.url else {
            return
        }
        deeplinkCoordinator?.handleURL(firstUrl)
    }
}
