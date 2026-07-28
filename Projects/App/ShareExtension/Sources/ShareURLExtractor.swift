//
//  ShareURLExtractor.swift
//  LivithShareExtension
//
//  Created by youz2me on 7/9/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import UniformTypeIdentifiers

enum ShareURLExtractor {
    static func makeDeepLink(from sharedURL: URL) -> URL? {
        var components = URLComponents()
        components.scheme = Constants.scheme
        components.host = Constants.host
        components.queryItems = [URLQueryItem(name: Constants.urlQueryName, value: sharedURL.absoluteString)]

        return components.url
    }

    static func firstURL(in items: [NSExtensionItem]) async -> URL? {
        for item in items {
            guard let attachments = item.attachments else { continue }

            for provider in attachments {
                if let url = await loadURL(from: provider) {
                    return url
                }
            }
        }

        return nil
    }
}

// MARK: - Helpers

private extension ShareURLExtractor {
    static func loadURL(from provider: NSItemProvider) async -> URL? {
        if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier),
           let url = await loadItem(from: provider, typeIdentifier: UTType.url.identifier) as? URL {
            return url
        }

        if provider.hasItemConformingToTypeIdentifier(UTType.text.identifier),
           let text = await loadItem(from: provider, typeIdentifier: UTType.text.identifier) as? String,
           let url = firstURL(inText: text) {
            return url
        }

        return nil
    }

    static func loadItem(from provider: NSItemProvider, typeIdentifier: String) async -> NSSecureCoding? {
        await withCheckedContinuation { continuation in
            provider.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { item, _ in
                continuation.resume(returning: item)
            }
        }
    }

    static func firstURL(inText text: String) -> URL? {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return nil
        }

        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        return detector.firstMatch(in: text, options: [], range: range)?.url
    }

    enum Constants {
        static let scheme = "livith"
        static let host = "instagram"
        static let urlQueryName = "url"
    }
}
