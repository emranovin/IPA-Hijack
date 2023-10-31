//
//  AccountDeeplinkHandler.swift
//
//  Created by Emran Novin on 9/9/23.
//

import UIKit

enum LinkHandlerError: Error, LocalizedError {
    case undefinedURL
    case invalidPlistURL
    case notFoundURL
    case unableToGetPlist
    
    var errorDescription: String? {
        switch self {
        case .invalidPlistURL:
            "The PList URL is invalid."
        case .notFoundURL:
            "The IPA URL is not founded."
        case .undefinedURL:
            "The URL is undefined."
        case .unableToGetPlist:
            "Something went wrong on getting plist file."
        }
    }
}

final class PlistDeeplinkHandler: DeeplinkHandlerProtocol {
        
    weak var delegate: PlistHandlerProtocol?
    
    // MARK: - DeeplinkHandlerProtocol
    func canOpenURL(_ url: URL) -> Bool {
        return url.absoluteString.hasPrefix(Constants.UrlScheme + "://")
    }
    
    func openURL(_ url: URL) {
        Task {
            do {
                guard canOpenURL(url) else {
                    delegate?.didEncounterError(LinkHandlerError.undefinedURL)
                    return
                }
                let plistLink = try extractPlistLink(url)
                let url = try await getIPALink(from: plistLink)
                delegate?.didHandleURL(url)
            } catch {
                delegate?.didEncounterError(error)
            }
        }
    }
    
    private func extractPlistLink(_ deepLink: URL) throws -> URL {
        let deepLinkBase = Constants.UrlScheme + "://?action=download-manifest&url="
        let newLink = deepLink.absoluteString.replacingOccurrences(of: deepLinkBase, with: "")
        
        guard let url = URL(string: newLink) else {
            throw LinkHandlerError.invalidPlistURL
        }
        return url
    }

    private func getIPALink(from plistLink: URL) async throws -> URL {
        guard let plistData = try? await getPropertyListFile(from: plistLink)
        else { throw LinkHandlerError.unableToGetPlist }
        
        guard let urlString = await find(key: "url", in: plistData) as? String,
              let url = URL(string: urlString)
        else { throw LinkHandlerError.notFoundURL }
        return url
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
