//
//  AccountDeeplinkHandler.swift
//  IPACatcher
//
//  Created by Emran Novin on 9/9/23.
//

import UIKit

final class PlistDeeplinkHandler: DeeplinkHandlerProtocol {
    
    private weak var rootViewController: UIViewController?
    
    init(_ rootViewController: UIViewController?) {
        self.rootViewController = rootViewController
    }
    
    // MARK: - DeeplinkHandlerProtocol
    
    func canOpenURL(_ url: URL) -> Bool {
        return url.absoluteString.hasPrefix(Constants.UrlScheme + "://")
    }
    
    func openURL(_ url: URL) {
        guard canOpenURL(url) else { return }
        let mainViewController = rootViewController as! MainViewController
//        mainViewController.view.backgroundColor = .green
        if let url = extractPlistLink(url) {
            mainViewController.url = url
        } else {
            mainViewController.url = URL(string: "https://I Can NOT handle this link")!
        }
    }
    
    private func extractPlistLink(_ deepLink: URL) -> URL? {
        print("deeplink:\(deepLink)")
        let deeplinkBase = Constants.UrlScheme + "://?action=download-manifest&url="
        let newLink = deepLink.absoluteString.replacingOccurrences(of: deeplinkBase, with: "")
        print("newLink:\(newLink)")
        return URL(string: newLink)
    }
    
    private func getIPALink(from plistLink: URL) {
        
    }
}
