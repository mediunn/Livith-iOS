//
//  LivithApp+InjectDependency.swift
//  Livith-iOS
//
//  Created by Youjin Lee on 11/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import Domain
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
import CalendarData
import HomeFeature

@MainActor
struct AppComposition {
    func makeRootView(in container: DIContainer) -> AppRootView {
        registerNetworkingClient(in: container)
        registerCalendarWebConfig(in: container)

        container.register(
            assemblers: [
                NotificationDataAssembler(),
                AuthDataAssembler(),
                CommentDataAssembler(),
                ConcertDataAssembler(),
                SearchDataAssembler(),
                SetlistDataAssembler(),
                SongDataAssembler(),
                UserDataAssembler(),
                PreferenceDataAssembler(),
                CalendarDataAssembler()
            ]
        )
        return AppRootView(
            concertRequestRepository: container.resolve(ConcertRequestRepository.self)
        )
    }
}

// MARK: - Registration

private extension AppComposition {
    func registerNetworkingClient(in container: any DependencyRegistable) {
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
        let (client, tokenManager) = NetworkingFactory.build(
            config: config,
            onAuthenticationExpired: onAuthenticationExpired
        )
        container.register(client, for: NetworkClient.self)
        container.register(tokenManager, for: TokenManager.self)
    }

    func registerCalendarWebConfig(in container: any DependencyRegistable) {
        let urlString = Bundle.main.infoDictionary?["CALENDAR_WEB_URL"] as? String
        let trimmed = urlString?.trimmingCharacters(in: .whitespacesAndNewlines)
        let url = trimmed.flatMap { value -> URL? in
            guard !value.isEmpty else { return nil }
            return URL(string: value)
        }
        container.register(CalendarWebConfig(url: url), for: CalendarWebConfig.self)
    }
}
