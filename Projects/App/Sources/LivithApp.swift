import SwiftUI

import DIContainer
import LivithFoundation

import FirebaseCore
import KakaoSDKCommon

@main
struct LivithApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    private let rootView: AppRootView

    // MARK: - LifeCycle

    init() {
        rootView = AppComposition().makeRootView(in: DIContainer.shared)
        initializeFirebase()
        initializeKakaoSDK()
    }

    var body: some Scene {
        WindowGroup {
            rootView
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
