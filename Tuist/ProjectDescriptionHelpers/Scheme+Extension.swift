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
            // FR-06 관심 콘서트 결과 시트 UI 확인용. 홈 진입 시 스텁 알림 5건이 시트로 뜬다.
            makeScheme(
                name: "\(name)-EntryAlertsTest",
                targetName: name,
                configuration: .debug,
                launchArguments: [.launchArgument(name: "STUB_ENTRY_ALERTS", isEnabled: true)]
            ),
            makeScheme(name: name, targetName: name, configuration: .release)
        ]
    }

    private static func makeScheme(
        name: String,
        targetName: String,
        configuration: ConfigurationName,
        launchArguments: [LaunchArgument] = []
    ) -> Scheme {
        let isDebug = configuration == .debug

        return Scheme.scheme(
            name: name,
            buildAction: .buildAction(targets: [.target(targetName)]),
            runAction: .runAction(
                configuration: configuration,
                attachDebugger: isDebug,
                arguments: .arguments(launchArguments: launchArguments)
            ),
            archiveAction: .archiveAction(configuration: configuration),
            profileAction: .profileAction(configuration: configuration),
            analyzeAction: .analyzeAction(configuration: configuration)
        )
    }
}
