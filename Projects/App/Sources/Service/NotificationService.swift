//
//  NotificationService.swift
//  Livith-iOS
//
//  Created by Youjin Lee on 2/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import UIKit
import UserNotifications

final class NotificationService: NSObject {
    static let shared = NotificationService()

    private override init() {
        super.init()
    }

    func configure() {
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() async {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: options)
    }

    func registerForRemoteNotifications() {
        UIApplication.shared.registerForRemoteNotifications()
    }

    func handleDeviceToken(_ deviceToken: Data) {
        // TODO: FCM 토큰 등록
    }

    func handleRegistrationError(_ error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
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
