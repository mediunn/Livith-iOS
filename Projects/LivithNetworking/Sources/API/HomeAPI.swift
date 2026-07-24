//
//  HomeAPI.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum HomeAPI {
    public static func fetchSectionList() -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/home/sections",
            method: .get,
            task: .plain,
            authentication: .none
        )
    }

    public static func fetchInterestedConcertList(
        sort: String?,
        size: Int?,
        cursorDate: String?,
        cursorID: Int?
    ) -> NetworkEndpoint {
        var queryItems: [URLQueryItem] = []
        if let sort { queryItems.append(URLQueryItem(name: "sort", value: sort)) }
        if let size { queryItems.append(URLQueryItem(name: "size", value: String(size))) }
        if let cursorDate { queryItems.append(URLQueryItem(name: "cursorDate", value: cursorDate)) }
        if let cursorID { queryItems.append(URLQueryItem(name: "cursorId", value: String(cursorID))) }

        return NetworkEndpoint(
            path: "/users/interest-concerts",
            method: .get,
            task: .query(queryItems),
            authentication: .required,
            cache: .enabled
        )
    }

    public static func checkInterestedConcert(concertID: Int) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/users/interest-concerts/\(concertID)/exists",
            method: .get,
            task: .plain,
            authentication: .required
        )
    }

    public static func updateInterestedConcert(concertID: Int) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/users/interest-concert/\(concertID)",
            method: .post,
            task: .plain,
            authentication: .required
        )
    }

    public static func updateInterestedConcertList(concertIDList: [Int]) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/users/interest-concerts",
            method: .put,
            task: .body(DTO.Request.UpdateUserInterestConcertList(concertIDList: concertIDList)),
            authentication: .required
        )
    }

    public static func deleteInterestedConcert() -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/users/interest-concert",
            method: .delete,
            task: .plain,
            authentication: .required
        )
    }

    public static func fetchRecommendedConcertList() -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/recommendation/concerts",
            method: .get,
            task: .plain,
            authentication: .required
        )
    }

    public static func fetchInterestConcertToast() -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/users/interest-concerts/toast",
            method: .get,
            task: .plain,
            authentication: .required
        )
    }

    public static func markInterestConcertToastShown() -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/users/interest-concerts/toast",
            method: .patch,
            task: .plain,
            authentication: .required
        )
    }
}
