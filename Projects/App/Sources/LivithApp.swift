import SwiftUI

import FirebaseCore
import KakaoSDKCommon

import LivithFoundation

@main
struct LivithApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // MARK: - LifeCycle

    init() {
        registerDependency()
        initializeFirebase()
        initializeKakaoSDK()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .task {
                    await NotificationService.shared.requestAuthorization()
                    NotificationService.shared.registerForRemoteNotifications()
                }
                .onOpenURL { url in
                    DeepLinkService.shared.handle(url: url)
                }
        }
    }
}

// MARK: - Firebase

private extension LivithApp {
    func initializeFirebase() {
        FirebaseApp.configure()
    }
}

// MARK: - KakaoSDK

private extension LivithApp {
    func initializeKakaoSDK() {
        guard let kakaoAppKey = Bundle.main.infoDictionary?["NATIVE_APP_KEY"] as? String else { return }
        KakaoSDK.initSDK(appKey: kakaoAppKey)
    }
}
