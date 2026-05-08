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

    public static func livithNetworking(_ module: LivithNetworkingModule) -> TargetDependency {
        return .project(target: module.rawValue, path: ProjectID.livithNetworking.path)
    }

    public static func login(_ module: LoginModule) -> TargetDependency {
        return .project(target: module.rawValue, path: ProjectID.login.path)
    }
    
    public static func search(_ module: SearchModule) -> TargetDependency {
        return .project(target: module.rawValue, path: ProjectID.search.path)
    }

    public static func external(_ dependency: ExternalDependency) -> TargetDependency {
        return .external(name: dependency.rawValue)
    }
    
    public static func user(_ module: UserModule) -> TargetDependency {
        return .project(target: module.rawValue, path: ProjectID.user.path)
    }

    public static func home(_ module: HomeModule) -> TargetDependency {
        return .project(target: module.rawValue, path: ProjectID.home.path)
    }

    public static func concert(_ module: ConcertModule) -> TargetDependency {
        return .project(target: module.rawValue, path: ProjectID.concert.path)
    }

    public static func setlist(_ module: SetlistModule) -> TargetDependency {
        return .project(target: module.rawValue, path: ProjectID.setlist.path)
    }

    public static func song(_ module: SongModule) -> TargetDependency {
        return .project(target: module.rawValue, path: ProjectID.song.path)
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

    public static func designSystem(_ module: DesignSystemModule) -> TargetDependency {
        return .project(target: module.rawValue, path: ProjectID.designSystem.path)
    }
}
