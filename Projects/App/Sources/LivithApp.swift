import SwiftUI

import KakaoSDKCommon
import KakaoSDKAuth

@main
struct LivithApp: App {
    @State private var isLaunchScreenVisible = true
    
    // MARK: - LifeCycle

    init() {
        registerDependency()
        
        initializeKakaoSDK()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                AppRootView()
                    .onOpenURL { url in
                        openKakaoLoginURL(url)
                    }

                if isLaunchScreenVisible {
                    LaunchScreenView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                isLaunchScreenVisible = false
                            }
                        }
                }
            }
            .animation(.easeInOut(duration: 0.5), value: isLaunchScreenVisible)
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
