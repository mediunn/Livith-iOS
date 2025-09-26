import ProjectDescription

let project = Project(
    name: "Livith-iOS",
    targets: [
        .target(
            name: "Livith-iOS",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.Livith-iOS",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["Livith-iOS/Sources/**"],
            resources: ["Livith-iOS/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "Livith-iOSTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.Livith-iOSTests",
            infoPlist: .default,
            sources: ["Livith-iOS/Tests/**"],
            resources: [],
            dependencies: [.target(name: "Livith-iOS")]
        ),
    ]
)
