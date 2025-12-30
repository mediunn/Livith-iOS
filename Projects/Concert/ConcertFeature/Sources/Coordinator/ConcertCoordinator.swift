//
//  ConcertCoordinator.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import SwiftUI
import UIKit

import DSKit

public final class ConcertCoordinator: Coordinator {
    public typealias R = ConcertRoute

    public let navigationController: UINavigationController

    private let onDismiss: () -> Void

    // MARK: - Initializer

    public init(
        navigationController: UINavigationController,
        onDismiss: @escaping () -> Void = {}
    ) {
        self.navigationController = navigationController
        self.onDismiss = onDismiss
    }

    // MARK: - Coordinator

    public func start() {}

    public func start(concertID: Int) {
        push(to: .detail(concertID: concertID))
    }

    public func buildViewController(for route: ConcertRoute) -> UIViewController {
        switch route {
        case .detail(let concertID):
            let view = ConcertView(
                concertID: concertID,
                onDismiss: { [weak self] in
                    self?.pop()
                    self?.onDismiss()
                }
            )
            .environment(\.concertCoordinator, self)

            return UIHostingController(rootView: view)

        case .safari(let url):
            let safariView = SafariView(url: url) { [weak self] in
                self?.dismiss()
            }.ignoresSafeArea()

            return UIHostingController(rootView: safariView)
        }
    }
}
