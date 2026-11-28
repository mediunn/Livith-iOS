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
    case feature(FeatureModule)
    case widget(WidgetModule)
    case domain(DomainModule)
    case data(DataModule)
    case shared(SharedModule)

    public var name: String {
        switch self {
        case .app: return BuildConfiguration.appName
        case .core(let module): return module.rawValue
        case .feature(let module): return module.rawValue
        case .widget(let module): return module.rawValue
        case .domain(let module): return module.rawValue
        case .data(let module): return module.rawValue
        case .shared(let module): return module.rawValue
        }
    }
    
    public var bundleID: String {
        switch self {
        case .app:
            return BuildConfiguration.baseBundleID
        case .core(.analytics):
            return "\(BuildConfiguration.baseBundleID).amplitude"
        case .core(.routing):
            return "\(BuildConfiguration.baseBundleID).coordinator"
        case .core(.livithNetwork):
            return "\(BuildConfiguration.baseBundleID).livithnetworking"
        case .core(.livithNetworkTests):
            return "\(BuildConfiguration.baseBundleID).livithnetworkingtests"
        default:
            return "\(BuildConfiguration.baseBundleID).\(name.lowercased())"
        }
    }
    
    public var sourcesPath: SourceFilesList {
        switch self {
        case .app:
            return ["Sources/**"]
        case .core(.livithNetworkTests):
            return ["LivithNetwork/Tests/**"]
        case .core(let module):
            return ["\(module.rawValue)/Sources/**"]
        case .feature(let module):
            let targetName = module.rawValue
            let testSuffix = "Tests"
            if targetName.hasSuffix(testSuffix) {
                return ["\(targetName.dropLast(testSuffix.count))/Tests/**"]
            }
            return ["\(targetName)/Sources/**"]
        case .widget:
            return ["Sources/**"]
        case .domain:
            return ["Sources/**"]
        case .data(let module):
            return dataModuleTestSourcePath(module) ?? ["\(module.rawValue)/Sources/**"]
        case .shared(let module):
            return sharedSourcePath(module)
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
        case .shared(.designSystem):
            return ["LivithDesignSystem/Resources/**"]
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
            .preferenceDataTests: "PreferenceData",
            .searchDataTests: "SearchData",
            .setlistDataTests: "SetlistData",
            .songDataTests: "SongData",
            .userDataTests: "UserData",
            .notificationDataTests: "NotificationData",
            .calendarDataTests: "CalendarData"
        ]

        guard let parentModule = testModuleMappings[module] else { return nil }
        return ["\(parentModule)/Tests/**"]
    }

    func sharedSourcePath(_ module: SharedModule) -> SourceFilesList {
        switch module {
        case .displaySupport:
            return ["DisplaySupport/Sources/**"]
        case .displaySupportTests:
            return ["DisplaySupport/Tests/**"]
        case .designSystem:
            return ["LivithDesignSystem/Sources/**"]
        }
    }
}
