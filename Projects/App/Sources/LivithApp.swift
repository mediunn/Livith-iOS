import SwiftUI

import KakaoSDKCommon
import KakaoSDKAuth

@main
struct LivithApp: App {
    
    // MARK: - LifeCycle

    init() {
        registerDependency()
        
        initializeKakaoSDK()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .onOpenURL { url in
                    openKakaoLoginURL(url)
                }
        }
    }
}

// MARK: - KakaoSDK

private extension LivithApp {
    typealias KakaoAuthAPI = AuthApi
    
    func initializeKakaoSDK() {
        guard let kakaoAppKey = Bundle.main.infoDictionary?["NATIVE_APP_KEY"] as? String else { return }
        KakaoSDK.initSDK(appKey: kakaoAppKey)
    }
    
    func openKakaoLoginURL(_ url: URL) {
        guard KakaoAuthAPI.isKakaoTalkLoginUrl(url) else { return }
        _ = AuthController.handleOpenUrl(url: url)
    }
}
