//
//  ConcertAPI.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum ConcertAPI {
    public static func fetchConcertInfo(concertID: Int) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/concerts/\(concertID)",
            method: .get,
            task: .plain,
            authentication: .none
        )
    }

    public static func fetchConcertSchedule(concertID: Int) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/concerts/\(concertID)/schedule",
            method: .get,
            task: .plain,
            authentication: .none
        )
    }

    public static func fetchConcertCultureList(concertID: Int) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/concerts/\(concertID)/cultures",
            method: .get,
            task: .plain,
            authentication: .none
        )
    }

    public static func fetchConcertInfoList(concertID: Int) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/concerts/\(concertID)/info",
            method: .get,
            task: .plain,
            authentication: .none
        )
    }

    public static func fetchConcertMerchandiseList(concertID: Int) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/concerts/\(concertID)/mds",
            method: .get,
            task: .plain,
            authentication: .none
        )
    }

    public static func fetchConcertSetlistList(concertID: Int) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/concerts/\(concertID)/setlists",
            method: .get,
            task: .plain,
            authentication: .none
        )
    }

    public static func fetchConcertArtistInfo(concertID: Int) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/concerts/\(concertID)/artist",
            method: .get,
            task: .plain,
            authentication: .none
        )
    }

    public static func requestConcert(
        title: String,
        url: String?,
        shouldAutoRegister: Bool,
        requestContent: String?
    ) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/concerts/requests",
            method: .post,
            task: .body(DTO.Request.RequestConcert(
                title: title,
                url: url,
                autoRegister: shouldAutoRegister,
                requestContent: requestContent
            )),
            authentication: .required
        )
    }
}
