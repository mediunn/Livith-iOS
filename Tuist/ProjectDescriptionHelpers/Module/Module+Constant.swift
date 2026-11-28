//
//  Modules.swift
//  Manifests
//
//  Created by 김진웅 on 11/2/25.
//

import ProjectDescription

// MARK: - Core Module

public enum CoreModule: String {
    case diContainer = "DIContainer"
    case persistence = "Persistence"
    case livithFoundation = "LivithFoundation"
    case socialAuth = "SocialAuth"
    case routing = "Routing"
    case analytics = "Analytics"
    case livithNetwork = "LivithNetwork"
    case livithNetworkTests = "LivithNetworkTests"
}

// MARK: - Feature Module

public enum FeatureModule: String {
    case concertFeature = "ConcertFeature"
    case concertSearch = "ConcertSearch"
    case concertSearchTests = "ConcertSearchTests"
    case homeFeature = "HomeFeature"
    case homeFeatureTests = "HomeFeatureTests"
    case loginFeature = "LoginFeature"
    case nicknameEditFeature = "NicknameEditFeature"
    case nicknameEditFeatureTests = "NicknameEditFeatureTests"
    case preferenceFeature = "PreferenceFeature"
    case preferenceFeatureTests = "PreferenceFeatureTests"
    case searchFeature = "SearchFeature"
    case searchFeatureTests = "SearchFeatureTests"
    case setlistFeature = "SetlistFeature"
    case shareFeature = "ShareFeature"
    case shareFeatureTests = "ShareFeatureTests"
    case songFeature = "SongFeature"
    case userFeature = "UserFeature"
}

// MARK: - Widget Module

public enum WidgetModule: String {
    case widget = "LivithWidget"
}

// MARK: - Domain Module

public enum DomainModule: String {
    case domain = "Domain"
}

// MARK: - Data Module

public enum DataModule: String {
    case data = "Data"
    case authData = "AuthData"
    case authDataTests = "AuthDataTests"
    case commentData = "CommentData"
    case commentDataTests = "CommentDataTests"
    case concertData = "ConcertData"
    case concertDataTests = "ConcertDataTests"
    case preferenceData = "PreferenceData"
    case preferenceDataTests = "PreferenceDataTests"
    case searchData = "SearchData"
    case searchDataTests = "SearchDataTests"
    case setlistData = "SetlistData"
    case setlistDataTests = "SetlistDataTests"
    case songData = "SongData"
    case songDataTests = "SongDataTests"
    case userData = "UserData"
    case userDataTests = "UserDataTests"
    case notificationData = "NotificationData"
    case notificationDataTests = "NotificationDataTests"
    case calendarData = "CalendarData"
    case calendarDataTests = "CalendarDataTests"
    case dataTests = "DataTests"
}

// MARK: - Shared Module

public enum SharedModule: String {
    case displaySupport = "DisplaySupport"
    case displaySupportTests = "DisplaySupportTests"
    case designSystem = "LivithDesignSystem"
}

// MARK: - External Dependency

public enum ExternalDependency: String {
    case kingfisher = "Kingfisher"
    case kakaoSDKCommon = "KakaoSDKCommon"
    case kakaoSDKAuth = "KakaoSDKAuth"
    case kakaoSDKUser = "KakaoSDKUser"
    case youTubePlayerKit = "YouTubePlayerKit"
    case firebaseCore = "FirebaseCore"
    case firebaseMessaging = "FirebaseMessaging"
    case amplitudeSwift = "AmplitudeSwift"
}
