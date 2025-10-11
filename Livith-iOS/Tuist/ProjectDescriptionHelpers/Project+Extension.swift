//
//  Project+Extension.swift
//  Manifests
//
//  Created by Youjin Lee on 10/11/25.
//

import ProjectDescription

extension Project {
    public static func make(
        module: Module,
        packages: [Package] = [],
        settings: Settings? = nil,
        targets: [Target],
        schemes: [Scheme]? = nil
    ) -> Project {
        if let schemes = schemes {
            return Project(
                name: module.name,
                organizationName: BuildConfiguration.organizationName,
                packages: packages,
                settings: settings,
                targets: targets,
                schemes: schemes
            )
        } else {
            return Project(
                name: module.name,
                organizationName: BuildConfiguration.organizationName,
                packages: packages,
                settings: settings,
                targets: targets
            )
        }
    }
}
