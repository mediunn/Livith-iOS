// swift-tools-version: 6.0
@preconcurrency import PackageDescription

#if TUIST
@preconcurrency import ProjectDescription

let packageSettings = PackageSettings(
    productTypes: [
        "Kingfisher": .framework,
        "KakaoSDKCommon": .framework,
        "KakaoSDKAuth": .framework,
        "KakaoSDKUser": .framework,
        "Alamofire": .framework,
        "YouTubePlayerKit": .framework,
        "FirebaseMessaging": .staticLibrary,
        // ObjC FirebaseCore `@import`s this Swift target. A static library does not emit a clang module.
        "FirebaseCoreInternal": .staticFramework
    ]
)
#endif

let package = Package(
    name: "Livith-iOS",
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.12.2")),
        .package(url: "https://github.com/onevcat/Kingfisher", .upToNextMajor(from: "8.14.0")),
        .package(url: "https://github.com/kakao/kakao-ios-sdk", .upToNextMajor(from: "2.29.0")),
        .package(url: "https://github.com/SvenTiigi/YouTubePlayerKit", .upToNextMajor(from: "1.9.0")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: "12.9.0"),
        .package(url: "https://github.com/amplitude/Amplitude-Swift", .upToNextMajor(from: "1.0.0"))
    ]
)
