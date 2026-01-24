//
//  TargetID.swift
//  Manifests
//
//  Created by Youjin Lee on 11/2/25.
//

import ProjectDescription

// MARK: - TargetID

public enum TargetID {
    case app
    case core(CoreModule)
    case login(LoginModule)
    case search(SearchModule)
    case song(SongModule)
    case setlist(SetlistModule)
    case concert(ConcertModule)
    case home(HomeModule)
    case user(UserModule)
    case widget(WidgetModule)
    case domain(DomainModule)
    case data(DataModule)
    case sharedFeature(SharedFeatureModule)
    case designSystem(DesignSystemModule)

    public var name: String {
        switch self {
        case .app: return BuildConfiguration.appName
        case .core(let module): return module.rawValue
        case .login(let module): return module.rawValue
        case .search(let module): return module.rawValue
        case .song(let module): return module.rawValue
        case .setlist(let module): return module.rawValue
        case .concert(let module): return module.rawValue
        case .home(let module): return module.rawValue
        case .user(let module): return module.rawValue
        case .widget(let module): return module.rawValue
        case .domain(let module): return module.rawValue
        case .data(let module): return module.rawValue
        case .sharedFeature(let module): return module.rawValue
        case .designSystem(let module): return module.rawValue
        }
    }
    
    public var bundleID: String {
        switch self {
        case .app:
            return BuildConfiguration.baseBundleID
        default:
            return "\(BuildConfiguration.baseBundleID).\(name.lowercased())"
        }
    }
    
    public var sourcesPath: SourceFilesList {
        switch self {
        case .app:
            return ["Sources/**"]
        case .core(let module):
            return ["\(module.rawValue)/Sources/**"]
        case .login:
            return ["Sources/**"]
        case .search:
            return ["Sources/**"]
        case .song:
            return ["Sources/**"]
        case .setlist:
            return ["Sources/**"]
        case .concert:
            return ["Sources/**"]
        case .home:
            return ["Sources/**"]
        case .user:
            return ["Sources/**"]
        case .widget:
            return ["Sources/**"]
        case .domain:
            return ["Sources/**"]
        case .data(let module):
            return dataModuleTestSourcePath(module) ?? ["\(module.rawValue)/Sources/**"]
        case .sharedFeature(let module):
            return sharedFeatureSourcePath(module)
        case .designSystem:
            return ["Sources/**"]
        }
    }
    
    public var resourcesPath: ResourceFileElements? {
        switch self {
        case .app:
            return [
                .glob(pattern: "Resources/**", excluding: [
                    "Resources/App-Info.plist",
                    "Resources/Livith-iOS.entitlements"
                ])
            ]
        case .widget:
            return [
                .glob(pattern: "Resources/**", excluding: [
                    "Resources/LivithWidget.entitlements"
                ])
            ]
        case .designSystem:
            return ["Resources/**"]
        default:
            return nil
        }
    }
}

// MARK: - Helpers

private extension TargetID {
    func dataModuleTestSourcePath(_ module: DataModule) -> SourceFilesList? {
        let testModuleMappings: [DataModule: String] = [
            .authDataTests: "AuthData",
            .commentDataTests: "CommentData",
            .concertDataTests: "ConcertData",
            .searchDataTests: "SearchData",
            .setlistDataTests: "SetlistData",
            .songDataTests: "SongData",
            .userDataTests: "UserData"
        ]

        guard let parentModule = testModuleMappings[module] else { return nil }
        return ["\(parentModule)/Tests/**"]
    }

    func sharedFeatureSourcePath(_ module: SharedFeatureModule) -> SourceFilesList {
        switch module {
        case .nicknameEditFeature:
            return ["NicknameEditFeature/Sources/**"]
        case .nicknameEditFeatureTests:
            return ["NicknameEditFeature/Tests/**"]
        }
    }
}
