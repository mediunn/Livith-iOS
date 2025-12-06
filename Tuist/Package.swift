// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: ["Kingfisher": .framework]
    )
#endif

let package = Package(
    name: "Livith-iOS",
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", .upToNextMajor(from: "5.10.2")),
        .package(url: "https://github.com/onevcat/Kingfisher", .upToNextMajor(from: "8.2.0")),
        .package(url: "https://github.com/kakao/kakao-ios-sdk", .upToNextMajor(from: "2.26.0"))
    ]
)
