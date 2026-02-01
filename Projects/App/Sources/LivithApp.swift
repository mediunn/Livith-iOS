import SwiftUI

import KakaoSDKCommon
import LivithFoundation

@main
struct LivithApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    // MARK: - LifeCycle

    init() {
        registerDependency()
        initializeKakaoSDK()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .task {
                    await NotificationService.shared.requestAuthorization()
                }
                .onOpenURL { url in
                    DeepLinkService.shared.handle(url: url)
                }
        }
    }
}

// MARK: - KakaoSDK

private extension LivithApp {
    func initializeKakaoSDK() {
        guard let kakaoAppKey = Bundle.main.infoDictionary?["NATIVE_APP_KEY"] as? String else { return }
        KakaoSDK.initSDK(appKey: kakaoAppKey)
    }
}
