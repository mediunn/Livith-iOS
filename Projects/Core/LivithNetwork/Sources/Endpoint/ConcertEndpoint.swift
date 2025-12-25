//
//  ConcertEndpoint.swift
//  LivithNetwork
//
//  Created by Youjin Lee on 12/25/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public typealias ConcertService = NetworkService<ConcertEndpoint>

public enum ConcertEndpoint {
    /// 1. 특정 콘서트 상세 조회
    case fetchConcertInfo(concertID: Int)
    /// 2. 특정 콘서트 일정 목록 조회
    case fetchConcertSchedule(concertID: Int)
    /// 12. 특정 콘서트 문화 목록 조회
    case fetchConcertCultureList(concertID: Int)
    /// 13. 특정 콘서트 필수 정보 목록 조회
    case fetchConcertKeyInfoList(concertID: Int)
    /// 14. 특정 콘서트 MD 목록 조회
    case fetchConcertMerchandiseList(concertID: Int)
    /// 15. 특정 콘서트 셋리스트 목록 조회
    case fetchConcertSetlistList(concertID: Int)
    /// 16. 특정 콘서트 아티스트 조회
    case fetchConcertArtistInfo(concertID: Int)
}

extension ConcertEndpoint: NetworkEndpoint {
    public var path: String? {
        switch self {
        case .fetchConcertInfo(let concertID):
            return "/api/v4/concerts/\(concertID)"
        case .fetchConcertSchedule(let concertID):
            return "/api/v4/concerts/\(concertID)/schedules"
        case .fetchConcertCultureList(let concertID):
            return "/api/v4/concerts/\(concertID)/cultures"
        case .fetchConcertKeyInfoList(let concertID):
            return "/api/v4/concerts/\(concertID)/key-infos"
        case .fetchConcertMerchandiseList(let concertID):
            return "/api/v4/concerts/\(concertID)/merchandises"
        case .fetchConcertSetlistList(let concertID):
            return "/api/v4/concerts/\(concertID)/setlists"
        case .fetchConcertArtistInfo(let concertID):
            return "/api/v4/concerts/\(concertID)/artist"
        }
    }

    public var query: [String: Any]? {
        switch self {
        case .fetchConcertInfo,
             .fetchConcertSchedule,
             .fetchConcertCultureList,
             .fetchConcertKeyInfoList,
             .fetchConcertMerchandiseList,
             .fetchConcertSetlistList,
             .fetchConcertArtistInfo:
            return nil
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .fetchConcertInfo,
             .fetchConcertSchedule,
             .fetchConcertCultureList,
             .fetchConcertKeyInfoList,
             .fetchConcertMerchandiseList,
             .fetchConcertSetlistList,
             .fetchConcertArtistInfo:
            return .get
        }
    }

    public var headers: HTTPHeaders? {
        switch self {
        case .fetchConcertInfo,
             .fetchConcertSchedule,
             .fetchConcertCultureList,
             .fetchConcertKeyInfoList,
             .fetchConcertMerchandiseList,
             .fetchConcertSetlistList,
             .fetchConcertArtistInfo:
            return nil
        }
    }

    public var body: Encodable? {
        switch self {
        case .fetchConcertInfo,
             .fetchConcertSchedule,
             .fetchConcertCultureList,
             .fetchConcertKeyInfoList,
             .fetchConcertMerchandiseList,
             .fetchConcertSetlistList,
             .fetchConcertArtistInfo:
            return nil
        }
    }

    public var requiresInterceptor: Bool {
        switch self {
        case .fetchConcertInfo,
             .fetchConcertSchedule,
             .fetchConcertCultureList,
             .fetchConcertKeyInfoList,
             .fetchConcertMerchandiseList,
             .fetchConcertSetlistList,
             .fetchConcertArtistInfo:
            return false
        }
    }
}
