//
//  Target+Extension.swift
//  Manifests
//
//  Created by Youjin Lee on 10/11/25.
//

import ProjectDescription

extension Target {
    public static func make(
        target: TargetID,
        destinations: Destinations = [.iPhone],
        product: Product,
        deploymentTargets: DeploymentTargets? = .iOS("17.0"),
        infoPlist: InfoPlist? = .default,
        entitlements: Entitlements? = nil,
        dependencies: [TargetDependency] = [],
        settings: Settings? = nil
    ) -> Target {
        return .target(
            name: target.name,
            destinations: destinations,
            product: product,
            bundleId: target.bundleID,
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: target.sourcesPath,
            resources: target.resourcesPath,
            entitlements: entitlements,
            dependencies: dependencies,
            settings: settings
        )
    }
    
    public static func make(
        name: String,
        destinations: Destinations = [.iPhone],
        product: Product,
        bundleID: String,
        deploymentTargets: DeploymentTargets? = .iOS("17.0"),
        infoPlist: InfoPlist? = .default,
        sources: SourceFilesList = ["Sources/**"],
        resources: ResourceFileElements? = nil,
        entitlements: Entitlements? = nil,
        dependencies: [TargetDependency] = [],
        settings: Settings? = nil
    ) -> Target {
        return .target(
            name: name,
            destinations: destinations,
            product: product,
            bundleId: bundleID,
            deploymentTargets: deploymentTargets,
            infoPlist: infoPlist,
            sources: sources,
            resources: resources,
            entitlements: entitlements,
            dependencies: dependencies,
            settings: settings
        )
    }
}
