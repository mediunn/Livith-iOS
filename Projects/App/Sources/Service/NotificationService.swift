//
//  NotificationService.swift
//  Livith-iOS
//
//  Created by Youjin Lee on 2/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import UIKit
import UserNotifications

import DIContainer
import Domain
import Persistence

import FirebaseMessaging

final class NotificationService: NSObject {
    static let shared = NotificationService()

    @Injected private var notificationRepository: NotificationRepository

    private override init() {
        super.init()
    }

    func configure() {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
    }

    func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }

    func requestAuthorization() async {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: options)
    }

    func handleDeviceToken(_ deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func handleRegistrationError(_ error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    func getFCMToken() async -> String? {
        try? await Messaging.messaging().token()
    }

    func registerFCMTokenToServer() {
        Task {
            guard let token = await getFCMToken() else { return }
            try? await notificationRepository.registerFCMToken(token)
        }
    }

    func registerFCMTokenIfLoggedIn() {
        let storage = UserDefaultsStorage()
        let isLoggedIn: Bool = (try? storage.fetch(for: .currentUser) as User) != nil
        guard isLoggedIn else { return }
        registerFCMTokenToServer()
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .badge, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        DeepLinkService.shared.handle(userInfo: userInfo)
        completionHandler()
    }
}

// MARK: - MessagingDelegate

extension NotificationService: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        print("FCM Token: \(fcmToken)")
        registerFCMTokenIfLoggedIn()
    }
}
