import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .feature,
    targets: [
        .make(
            target: .feature(.concertFeature),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .feature(.setlistFeature),
                .feature(.songFeature),
                .shared(.designSystem),
                .shared(.displaySupport),
                .core(.routing),
                .core(.diContainer),
                .core(.livithFoundation),
                .core(.persistence),
                .core(.analytics)
            ]
        ),
        .make(
            target: .feature(.homeFeature),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .feature(.concertFeature),
                .feature(.shareFeature),
                .feature(.userFeature),
                .shared(.designSystem),
                .feature(.concertSearch),
                .shared(.displaySupport),
                .feature(.nicknameEditFeature),
                .core(.routing),
                .core(.diContainer),
                .core(.livithFoundation),
                .core(.analytics)
            ]
        ),
        .make(
            target: .feature(.homeFeatureTests),
            product: .unitTests,
            dependencies: [
                .feature(.homeFeature),
                .feature(.nicknameEditFeature),
                .shared(.displaySupport)
            ]
        ),
        .make(
            target: .feature(.loginFeature),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .feature(.nicknameEditFeature),
                .shared(.displaySupport),
                .shared(.designSystem),
                .core(.routing),
                .core(.diContainer),
                .core(.analytics),
                .feature(.preferenceFeature)
            ]
        ),
        .make(
            target: .feature(.searchFeature),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .feature(.concertFeature),
                .shared(.designSystem),
                .feature(.concertSearch),
                .shared(.displaySupport),
                .core(.routing),
                .core(.diContainer),
                .core(.livithFoundation),
                .core(.analytics)
            ]
        ),
        .make(
            target: .feature(.searchFeatureTests),
            product: .unitTests,
            dependencies: [
                .feature(.searchFeature)
            ]
        ),
        .make(
            target: .feature(.setlistFeature),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .shared(.designSystem),
                .core(.routing),
                .core(.diContainer),
                .core(.livithFoundation),
                .core(.analytics)
            ]
        ),
        .make(
            target: .feature(.shareFeature),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .shared(.designSystem),
                .core(.analytics)
            ]
        ),
        .make(
            target: .feature(.shareFeatureTests),
            product: .unitTests,
            dependencies: [
                .feature(.shareFeature),
                .domain(.domain)
            ]
        ),
        .make(
            target: .feature(.songFeature),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .shared(.designSystem),
                .core(.routing),
                .core(.diContainer),
                .core(.livithFoundation),
                .core(.analytics),
                .external(.youTubePlayerKit)
            ]
        ),
        .make(
            target: .feature(.userFeature),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .feature(.nicknameEditFeature),
                .shared(.displaySupport),
                .shared(.designSystem),
                .core(.routing),
                .core(.diContainer),
                .core(.livithFoundation),
                .core(.persistence),
                .feature(.preferenceFeature)
            ]
        ),
        .make(
            target: .feature(.concertSearch),
            product: .framework,
            dependencies: [.domain(.domain)]
        ),
        .make(
            target: .feature(.concertSearchTests),
            product: .unitTests,
            dependencies: [.feature(.concertSearch), .domain(.domain)]
        ),
        .make(
            target: .feature(.nicknameEditFeature),
            product: .framework,
            dependencies: [
                .shared(.displaySupport),
                .shared(.designSystem),
                .core(.diContainer),
                .domain(.domain)
            ]
        ),
        .make(
            target: .feature(.nicknameEditFeatureTests),
            product: .unitTests,
            dependencies: [
                .feature(.nicknameEditFeature)
            ]
        ),
        .make(
            target: .feature(.preferenceFeature),
            product: .framework,
            dependencies: [
                .shared(.displaySupport),
                .shared(.designSystem),
                .core(.diContainer),
                .core(.analytics),
                .domain(.domain)
            ]
        ),
        .make(
            target: .feature(.preferenceFeatureTests),
            product: .unitTests,
            dependencies: [
                .feature(.preferenceFeature)
            ]
        )
    ]
)
