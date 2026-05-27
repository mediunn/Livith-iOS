//
//  HomeService.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

// MARK: - HomeService

public protocol HomeService: Sendable {
    func fetchSectionList() async throws(NetworkError) -> DTO.Response.FetchHomeSectionList
    func fetchInterestedConcertList(sort: String?, size: Int?, cursorDate: String?, cursorID: Int?) async throws(NetworkError) -> DTO.Response.FetchUserInterestConcert
    func checkInterestedConcert(concertID: Int) async throws(NetworkError) -> DTO.Response.CheckInterestedConcert
    func updateInterestedConcert(concertID: Int) async throws(NetworkError) -> DTO.Response.UpdateUserInterestConcert
    func updateInterestedConcertList(concertIDList: [Int]) async throws(NetworkError) -> DTO.Response.UpdateUserInterestConcertList
    func deleteInterestedConcert() async throws(NetworkError)
    func fetchRecommendedConcertList() async throws(NetworkError) -> DTO.Response.FetchRecommendedConcertList
    func fetchInterestConcertToast() async throws(NetworkError) -> DTO.Response.FetchInterestConcertToast
    func markInterestConcertToastShown() async throws(NetworkError) -> DTO.Response.UpdateInterestConcertToast
}

// MARK: - HomeServiceImpl

struct HomeServiceImpl: HomeService {
    private let networkClient: NetworkClient

    init(networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    public func fetchSectionList() async throws(NetworkError) -> DTO.Response.FetchHomeSectionList {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/home/sections",
                method: .get,
                task: .plain,
                authentication: .none
            )
        )
    }

    public func fetchInterestedConcertList(sort: String?, size: Int?, cursorDate: String?, cursorID: Int?) async throws(NetworkError) -> DTO.Response.FetchUserInterestConcert {
        var queryItems: [URLQueryItem] = []
        if let sort { queryItems.append(URLQueryItem(name: "sort", value: sort)) }
        if let size { queryItems.append(URLQueryItem(name: "size", value: String(size))) }
        if let cursorDate { queryItems.append(URLQueryItem(name: "cursorDate", value: cursorDate)) }
        if let cursorID { queryItems.append(URLQueryItem(name: "cursorId", value: String(cursorID))) }

        return try await networkClient.request(
            NetworkEndpoint(
                path: "/users/interest-concerts",
                method: .get,
                task: .query(queryItems),
                authentication: .required
            )
        )
    }

    public func checkInterestedConcert(concertID: Int) async throws(NetworkError) -> DTO.Response.CheckInterestedConcert {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/users/interest-concerts/\(concertID)/exists",
                method: .get,
                task: .plain,
                authentication: .required
            )
        )
    }

    public func updateInterestedConcert(concertID: Int) async throws(NetworkError) -> DTO.Response.UpdateUserInterestConcert {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/users/interest-concert",
                method: .post,
                task: .body(DTO.Request.UpdateUserInterestConcert(concertID: concertID)),
                authentication: .required
            )
        )
    }

    public func updateInterestedConcertList(concertIDList: [Int]) async throws(NetworkError) -> DTO.Response.UpdateUserInterestConcertList {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/users/interest-concerts",
                method: .put,
                task: .body(DTO.Request.UpdateUserInterestConcertList(concertIDList: concertIDList)),
                authentication: .required
            )
        )
    }

    public func deleteInterestedConcert() async throws(NetworkError) {
        let _: EmptyResponse = try await networkClient.request(
            NetworkEndpoint(
                path: "/users/interest-concert",
                method: .delete,
                task: .plain,
                authentication: .required
            )
        )
    }

    public func fetchRecommendedConcertList() async throws(NetworkError) -> DTO.Response.FetchRecommendedConcertList {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/recommendation/concerts",
                method: .get,
                task: .plain,
                authentication: .required
            )
        )
    }

    public func fetchInterestConcertToast() async throws(NetworkError) -> DTO.Response.FetchInterestConcertToast {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/users/interest-concerts/toast",
                method: .get,
                task: .plain,
                authentication: .required
            )
        )
    }

    public func markInterestConcertToastShown() async throws(NetworkError) -> DTO.Response.UpdateInterestConcertToast {
        return try await networkClient.request(
            NetworkEndpoint(
                path: "/users/interest-concerts/toast",
                method: .patch,
                task: .plain,
                authentication: .required
            )
        )
    }
}
