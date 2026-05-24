//
//  LivithApp+InjectDependency.swift
//  Livith-iOS
//
//  Created by Youjin Lee on 11/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import LivithNetworking
import AuthData
import CommentData
import ConcertData
import NotificationData
import SearchData
import SetlistData
import SongData
import UserData
import PreferenceData

extension LivithApp {
    func registerDependency() {
        registerNetworkingFactory()

        DIContainer.shared.register(
            assemblers: [
                NotificationDataAssembler(),
                AuthDataAssembler(),
                CommentDataAssembler(),
                ConcertDataAssembler(),
                SearchDataAssembler(),
                SetlistDataAssembler(),
                SongDataAssembler(),
                UserDataAssembler(),
                PreferenceDataAssembler()
            ]
        )
    }
}

// MARK: - Networking Factory Registration

private extension LivithApp {
    func registerNetworkingFactory() {
        guard let baseURLString = Bundle.main.infoDictionary?["BASE_URL"] as? String,
              let baseURL = URL(string: baseURLString)
        else {
            fatalError("BASE_URL is missing or invalid in Info.plist")
        }

        let onAuthenticationExpired: @Sendable () -> Void = {
            Task { @MainActor in
                NotificationCenter.default.post(
                    name: Notification.Name("reloginRequired"),
                    object: nil
                )
            }
        }

        let config = NetworkConfig(baseURL: baseURL)
        let factory = NetworkingFactoryImpl(
            config: config,
            onAuthenticationExpired: onAuthenticationExpired
        )
        DIContainer.shared.register(factory, for: NetworkingFactory.self)
    }
}
