//
//  ShareViewController.swift
//  LivithShareExtension
//
//  Created by youz2me on 7/9/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import UIKit

final class ShareViewController: UIViewController {

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear
        handleSharedItem()
    }
}

// MARK: - Helpers

private extension ShareViewController {
    func handleSharedItem() {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else {
            finish()
            return
        }

        Task {
            guard let sharedURL = await ShareURLExtractor.firstURL(in: items),
                  let deepLink = ShareURLExtractor.makeDeepLink(from: sharedURL)
            else {
                finish()
                return
            }

            await MainActor.run {
                openMainApp(with: deepLink)
                finish()
            }
        }
    }

    func openMainApp(with url: URL) {
        var responder: UIResponder? = self

        while let current = responder {
            if let application = current as? UIApplication {
                application.open(url, options: [:], completionHandler: nil)
                return
            }

            responder = current.next
        }
    }

    func finish() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
