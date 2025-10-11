//
//  Scheme+Extension.swift
//  Manifests
//
//  Created by Youjin Lee on 10/11/25.
//

import ProjectDescription

extension Scheme {
    public static func makeAppSchemes(name: String) -> [Scheme] {
        return [
            makeScheme(name: "\(name)-Dev", targetName: name, configuration: .debug),
            makeScheme(name: name, targetName: name, configuration: .release)
        ]
    }

    private static func makeScheme(
        name: String,
        targetName: String,
        configuration: ConfigurationName
    ) -> Scheme {
        return Scheme.scheme(
            name: name,
            buildAction: .buildAction(targets: [.target(targetName)]),
            runAction: .runAction(configuration: configuration),
            archiveAction: .archiveAction(configuration: configuration),
            profileAction: .profileAction(configuration: configuration),
            analyzeAction: .analyzeAction(configuration: configuration)
        )
    }
}
