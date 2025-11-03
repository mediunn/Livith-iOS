//
//  Settings+Extension.swift
//  Manifests
//
//  Created by Youjin Lee on 10/11/25.
//

import ProjectDescription

extension Settings {
    public static let environment: Settings = .settings(
        configurations: [
            .debug(name: .debug, xcconfig: .relativeToRoot("Tuist/Config/Development.xcconfig")),
            .release(name: .release, xcconfig: .relativeToRoot("Tuist/Config/Release.xcconfig"))
        ]
    )
}
