//
//  BuildConfiguration.swift
//  Manifests
//
//  Created by Youjin Lee on 10/10/25.
//

import ProjectDescription

public enum BuildConfiguration {
    case debug
    case release
}

// MARK: - Constant

extension BuildConfiguration {
    public static let appName = "Livith-iOS"
    public static let organizationName = "Livith"
}
