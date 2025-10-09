//
//  Target+Extension.swift
//  Manifests
//
//  Created by Youjin Lee on 10/11/25.
//

import ProjectDescription

extension Target {
    public static func make(
        module: Module,
        product: Product,
        name: String? = nil,
        infoPlist: InfoPlist = .default,
        sources: SourceFilesList = ["Sources/**"],
        resources: ResourceFileElements? = ["Resources/**"],
        dependencies: [TargetDependency] = []
    ) -> Target {
        return Target.target(
            name: name ?? module.name,
            destinations: [.iPhone],
            product: product,
            bundleId: BundleIdentifier.of(module),
            deploymentTargets: .iOS("17.0"),
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            dependencies: dependencies
        )
    }
}
