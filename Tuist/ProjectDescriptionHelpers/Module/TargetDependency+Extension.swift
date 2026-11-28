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

    public static func feature(_ module: FeatureModule) -> TargetDependency {
        return .project(target: module.rawValue, path: ProjectID.feature.path)
    }

    public static func external(_ dependency: ExternalDependency) -> TargetDependency {
        return .external(name: dependency.rawValue)
    }
    
    public static func widget(_ module: WidgetModule) -> TargetDependency {
        return .project(target: module.rawValue, path: ProjectID.widget.path)
    }

    public static func domain(_ module: DomainModule) -> TargetDependency {
        return .project(target: module.rawValue, path: ProjectID.domain.path)
    }

    public static func data(_ module: DataModule) -> TargetDependency {
        return .project(target: module.rawValue, path: ProjectID.data.path)
    }

    public static func shared(_ module: SharedModule) -> TargetDependency {
        return .project(target: module.rawValue, path: ProjectID.shared.path)
    }
}
