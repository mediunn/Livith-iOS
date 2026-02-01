import SwiftUI

import KakaoSDKAuth
import KakaoSDKCommon
import LivithFoundation

@main
struct LivithApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var isLaunchScreenVisible = true

    // MARK: - LifeCycle

    init() {
        registerDependency()

        initializeKakaoSDK()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .onOpenURL { url in
                    handleOpenURL(url)
                }
        }
    }
}

// MARK: - URL Handling

private extension LivithApp {
    func handleOpenURL(_ url: URL) {
        if AuthApi.isKakaoTalkLoginUrl(url) {
            _ = AuthController.handleOpenUrl(url: url)
            return
        }

        if url.scheme == "livith" {
            handleDeepLink(url)
        }
    }

    func handleDeepLink(_ url: URL) {
        guard let host = url.host else { return }

        switch host {
        case "concert":
            if let concertIDString = url.pathComponents.dropFirst().first,
               let concertID = Int(concertIDString) {
                NotificationCenter.default.post(
                    name: .openConcertDetail,
                    object: nil,
                    userInfo: ["concertID": concertID]
                )
            }
        case "home":
            break
        default:
            break
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

// MARK: - Notification.Name

public extension Notification.Name {
    static let openConcertDetail = Notification.Name("openConcertDetail")
}
