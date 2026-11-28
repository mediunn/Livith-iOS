//
//  Project.swift
//  Manifests
//
//  Created by YOUJIM on 4/14/25.
//


import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .app,
    settings: .environment,
    targets: [
        .make(
            target: .app,
            product: .app,
            infoPlist: .file(path: "Resources/App-Info.plist"),
            entitlements: .file(path: "Resources/Livith-iOS.entitlements"),
            dependencies: [
                .domain(.domain),
                .core(.diContainer),
                .feature(.concertSearch),
                .feature(.nicknameEditFeature),
                .feature(.concertFeature),
                .data(.commentData),
                .data(.concertData),
                .data(.notificationData),
                .feature(.homeFeature),
                .feature(.loginFeature),
                .data(.searchData),
                .feature(.searchFeature),
                .data(.setlistData),
                .feature(.setlistFeature),
                .data(.songData),
                .feature(.songFeature),
                .data(.authData),
                .data(.userData),
                .feature(.userFeature),
                .data(.preferenceData),
                .data(.calendarData),
                .core(.livithNetwork),
                .core(.analytics),
                .target(name: Constants.shareExtensionName)
            ],
            settings: .settings(
                base: ["OTHER_LDFLAGS": ["$(inherited)", "-ObjC"]]
            )
        ),
        .make(
            name: Constants.shareExtensionName,
            product: .appExtension,
            bundleID: "\(BuildConfiguration.baseBundleID).shareextension",
            infoPlist: .file(path: "ShareExtension/Resources/ShareExtension-Info.plist"),
            sources: ["ShareExtension/Sources/**"]
        )
    ],
    schemes: Scheme.makeAppSchemes(name: BuildConfiguration.appName)
)

private enum Constants {
    static let shareExtensionName = "LivithShareExtension"
}
