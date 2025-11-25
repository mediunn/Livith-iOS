//
//  Project.swift
//  Manifests
//
//  Created by Youjin Lee on 10/16/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: "search",
    organizationName: BuildConfiguration.organizationName,
    targets: [
        Target.make(
            module: .searchData,
            product: .framework,
            sources: ["Sources/SearchData/**"],
            dependencies: [
                .livithnetwork,
                .searchDomain
            ]
        ),
        Target.make(
            module: .searchDomain,
            product: .framework,
            sources: ["Sources/SearchDomain/**"],
            dependencies: []
        ),
        Target.make(
            module: .searchFeature,
            product: .framework,
            sources: ["Sources/SearchFeature/**"],
            resources: .default,
            dependencies: [
                .searchDomain,
                .designSystem
            ]
        )
    ]
)
