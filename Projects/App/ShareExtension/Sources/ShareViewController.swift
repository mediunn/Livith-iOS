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
                openMainApp(with: deepLink) { [weak self] in
                    self?.finish()
                }
            }
        }
    }

    // 익스텐션이 open 완료 전에 종료되면 딥링크 전달이 유실될 수 있어 completion에서 finish한다.
    func openMainApp(with url: URL, completion: @escaping () -> Void) {
        var responder: UIResponder? = self

        while let current = responder {
            if let application = current as? UIApplication {
                application.open(url, options: [:]) { _ in
                    completion()
                }
                return
            }

            responder = current.next
        }

        completion()
    }

    func finish() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
