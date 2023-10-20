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
        if let plistLink = extractPlistLink(url) {
            getIPALink(from: plistLink) { url in
                mainViewController.url = url ?? URL(string: "https://I.can-NOT-handle.this.link")!
            }
        } else {
            mainViewController.url = URL(string: "https://I.can-NOT-handle.this.link")!
        }
    }
    
    private func extractPlistLink(_ deepLink: URL) -> URL? {
        print("deeplink:\(deepLink)")
        let deeplinkBase = Constants.UrlScheme + "://?action=download-manifest&url="
        let newLink = deepLink.absoluteString.replacingOccurrences(of: deeplinkBase, with: "")
        print("newLink:\(newLink)")
        return URL(string: newLink)
    }

    private func getIPALink(from plistLink: URL, completion: @escaping (URL?) -> Void) {
        Task {
            do {
                let plistData = try await getPropertyListFile(from: plistLink)
                if let urlString = await find(key: "url", in: plistData) as? String,
                   let url = URL(string: urlString) {
                    completion(url)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }
    }

    private func getPropertyListFile(from url: URL) async throws -> Any {
        let (data, _) = try await URLSession.shared.data(from: url)
        return try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
    }

    private func find(key: String, in object: Any) async -> Any? {
        if let dictionary = object as? [String: Any] {
            if let value = dictionary[key] {
                return value
            } else {
                for (_, value) in dictionary {
                    if let result = await find(key: key, in: value) {
                        return result
                    }
                }
            }
        } else if let array = object as? [Any] {
            for element in array {
                if let result = await find(key: key, in: element) {
                    return result
                }
            }
        }

        return nil
    }
}
