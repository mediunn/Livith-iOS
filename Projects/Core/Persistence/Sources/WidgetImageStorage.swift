//
//  WidgetImageStorage.swift
//  Persistence
//
//  Created by Youjin Lee on 1/16/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation
import UIKit

import LivithFoundation

public struct WidgetImageStorage {
    private static let appGroupID = "group.com.youz2me.livith"

    private let fileManager: FileManager
    private let containerURL: URL?

    public init(
        fileManager: FileManager = .default,
        appGroupID: String? = nil
    ) {
        self.fileManager = fileManager
        self.containerURL = fileManager.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID ?? Self.appGroupID
        )
    }

    public func save(_ data: Data, forKey key: String) {
        guard let fileURL = containerURL?.appendingPathComponent(key) else { return }

        do {
            try data.write(to: fileURL)
        } catch {
            #if DEBUG
            print("[WidgetImageStorage] Failed to save data for key '\(key)': \(error)")
            #endif
        }
    }

    public func load(forKey key: String) -> Data? {
        guard let fileURL = containerURL?.appendingPathComponent(key) else { return nil }

        return try? Data(contentsOf: fileURL)
    }

    public func remove(forKey key: String) {
        guard let fileURL = containerURL?.appendingPathComponent(key) else { return }

        try? fileManager.removeItem(at: fileURL)
    }

    public func download(from urlString: String, forKey key: String) async {
        guard let url = URL(string: urlString) else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data),
               let resizedData = image.downsampledData() {
                save(resizedData, forKey: key)
            } else {
                save(data, forKey: key)
            }
        } catch {
            #if DEBUG
            print("[WidgetImageStorage] Failed to download and save for key '\(key)': \(error)")
            #endif
        }
    }
}
