//
//  UserAPI.swift
//  LivithNetworking
//
//  Created by 김진웅 on 5/27/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum UserAPI {
    public static func logout(refreshToken: String) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/auth/logout",
            method: .post,
            task: .body(DTO.Request.RequestLogout(refreshToken: refreshToken)),
            authentication: .none
        )
    }

    public static func checkNicknameDuplicate(nickname: String) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/users/check-nickname",
            method: .get,
            task: .query([URLQueryItem(name: "nickname", value: nickname)]),
            authentication: .none
        )
    }

    public static func updateNickname(_ nickname: String) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/users/nickname",
            method: .patch,
            task: .body(DTO.Request.UpdateUserNickname(nickname: nickname)),
            authentication: .required
        )
    }

    public static func withdraw(reason: String) -> NetworkEndpoint {
        NetworkEndpoint(
            path: "/auth/withdraw",
            method: .post,
            task: .body(DTO.Request.DeleteUser(reason: reason)),
            authentication: .required
        )
    }
}
