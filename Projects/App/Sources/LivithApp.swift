import SwiftUI

import DIContainer
import Domain
import HomeFeature
import LivithFoundation

import FirebaseCore
import KakaoSDKCommon

@main
struct LivithApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    private let concertRequestRepository: any ConcertRequestRepository

    // MARK: - LifeCycle

    init() {
        Self.registerDependency()
        concertRequestRepository = DIContainer.shared.resolve(ConcertRequestRepository.self)
        initializeFirebase()
        initializeKakaoSDK()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(\.concertRequestRepository, concertRequestRepository)
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
