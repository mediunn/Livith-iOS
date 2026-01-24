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
    case search = "SearchFeature"
    case login = "LoginFeature"
    case user = "UserFeature"
    case home = "HomeFeature"
    case concert = "ConcertFeature"
    case setlist = "SetlistFeature"
    case song = "SongFeature"
    case widget = "Widget"
    case domain = "Domain"
    case data = "Data"
    public var name: String { rawValue }
    
    public var path: Path {
        .relativeToRoot("Projects/\(rawValue)")
    }
}
