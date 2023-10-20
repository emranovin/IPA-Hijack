//
//  BlogsDeeplinkHandler.swift
//
//  Created by Emran Novin on 9/9/23.
//

import UIKit

final class TestDeeplinkHandler: DeeplinkHandlerProtocol {
    
    private weak var rootViewController: UIViewController?
    init(_ rootViewController: UIViewController?) {
        self.rootViewController = rootViewController
    }
    
    // MARK: - DeeplinkHandlerProtocol
    
    func canOpenURL(_ url: URL) -> Bool {
        return url.absoluteString.hasPrefix(Constants.UrlScheme + "://blogs")
    }
    
    func openURL(_ url: URL) {
        guard canOpenURL(url) else {
            return
        }
        
        // mock the navigation
        let viewController = UIViewController()
        switch url.path {
        case "/new":
            viewController.title = "Blog Editing"
            viewController.view.backgroundColor = .orange
        default:
            viewController.title = "Blog Listing"
            viewController.view.backgroundColor = .cyan
        }
        
        DispatchQueue.main.async {
            self.rootViewController?.present(viewController, animated: true)
        }
    }
}
