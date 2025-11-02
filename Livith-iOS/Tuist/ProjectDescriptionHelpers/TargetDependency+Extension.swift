//
//  TargetDependency+Extension.swift
//  Manifests
//
//  Created by Youjin Lee on 10/11/25.
//

import ProjectDescription

// MARK: - TargetDependency Extension

extension TargetDependency {
    public static func core(_ module: CoreModule) -> TargetDependency {
        return .project(target: module.rawValue, path: ProjectID.core.path)
    }

    public static func shared(_ module: SharedModule) -> TargetDependency {
        return .project(target: module.rawValue, path: ProjectID.shared.path)
    }

    public static func login(_ module: LoginModule) -> TargetDependency {
        return .project(target: module.rawValue, path: ProjectID.login.path)
    }

    public static func external(_ dependency: ExternalDependency) -> TargetDependency {
        return .external(name: dependency.rawValue)
    }
}
