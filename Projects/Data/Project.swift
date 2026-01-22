
import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.make(
    project: .data,
    targets: [
        .make(
            target: .data(.data),
            product: .framework,
            dependencies: [
                .domain(.domain),
                .core(.diContainer),
                .core(.livithFoundation),
                .core(.livithNetwork),
                .core(.persistence),
                .core(.socialAuth)
            ]
        ),
        .make(
            target: .data(.dataTests),
            product: .unitTests,
            dependencies: [
                .data(.data)
            ]
        )
    ]
)
