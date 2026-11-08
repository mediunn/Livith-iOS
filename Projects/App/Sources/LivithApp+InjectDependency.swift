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
import CalendarData
import HomeFeature
import ConcertFeature

extension LivithApp {
    func registerDependency() {
        registerNetworkingClient()
        registerCalendarWebConfig()
        registerSetlistWebConfig()

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
                PreferenceDataAssembler(),
                CalendarDataAssembler()
            ]
        )
    }
}

// MARK: - Networking Client Registration

private extension LivithApp {
    func registerNetworkingClient() {
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
        DIContainer.shared.register(client, for: NetworkClient.self)
        DIContainer.shared.register(tokenManager, for: TokenManager.self)
    }

    func registerCalendarWebConfig() {
        let urlString = Bundle.main.infoDictionary?["CALENDAR_WEB_URL"] as? String
        let trimmed = urlString?.trimmingCharacters(in: .whitespacesAndNewlines)
        let url = trimmed.flatMap { value -> URL? in
            guard !value.isEmpty else { return nil }
            return URL(string: value)
        }
        DIContainer.shared.register(CalendarWebConfig(url: url), for: CalendarWebConfig.self)
    }

    func registerSetlistWebConfig() {
        let urlString = Bundle.main.infoDictionary?["WEB_BASE_URL"] as? String
        let trimmed = urlString?.trimmingCharacters(in: .whitespacesAndNewlines)
        let configuredURL = trimmed.flatMap { value -> URL? in
            guard !value.isEmpty else { return nil }
            return URL(string: value)
        }
        #if DEBUG
        /// `true`로 변경하면 시뮬레이터에서 로컬 웹 서버를 사용합니다.
        let useLocalWeb = true
        let baseURL = useLocalWeb ? URL(string: "http://localhost:5173") : configuredURL
        #else
        let baseURL = configuredURL
        #endif
        DIContainer.shared.register(SetlistWebConfig(baseURL: baseURL), for: SetlistWebConfig.self)
    }
}
