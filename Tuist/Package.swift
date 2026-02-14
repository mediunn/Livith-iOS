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
        "FirebaseMessaging": .staticLibrary
    ]
)
#endif

let package = Package(
    name: "Livith-iOS",
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.10.2")),
        .package(url: "https://github.com/onevcat/Kingfisher", .upToNextMajor(from: "8.2.0")),
        .package(url: "https://github.com/kakao/kakao-ios-sdk", .upToNextMajor(from: "2.26.0")),
        .package(url: "https://github.com/SvenTiigi/YouTubePlayerKit", .upToNextMajor(from: "1.9.0")),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: "12.9.0"),
        .package(url: "https://github.com/amplitude/Amplitude-Swift", .upToNextMajor(from: "1.0.0"))
    ]
)
