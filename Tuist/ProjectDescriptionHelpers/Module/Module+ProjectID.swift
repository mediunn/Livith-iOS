//
//  ProjectID.swift
//  Manifests
//
//  Created by Youjin Lee on 11/2/25.
//

import ProjectDescription

// MARK: - ProjectID

public enum ProjectID: String, CaseIterable {
    case app = "App"
    case core = "Core"
    case livithNetworking = "LivithNetworking"
    case search = "SearchFeature"
    case login = "LoginFeature"
    case user = "UserFeature"
    case home = "HomeFeature"
    case concert = "ConcertFeature"
    case setlist = "SetlistFeature"
    case song = "SongFeature"
    case share = "ShareFeature"
    case widget = "Widget"
    case domain = "Domain"
    case data = "Data"
    case shared = "Shared"
    case designSystem = "DesignSystem"

    public var name: String { rawValue }
    
    public var path: Path {
        .relativeToRoot("Projects/\(rawValue)")
    }
}
