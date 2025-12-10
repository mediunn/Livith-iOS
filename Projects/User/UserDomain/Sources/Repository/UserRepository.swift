//
//  UserRepository.swift
//  User
//
//  Created by Youjin Lee on 12/11/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

public protocol UserRepository {
    func checkNicknameDuplicate(nickname: String) async throws(UserError) -> Bool
    func changeNewNickname(nickname: String) async throws(UserError) -> String
    func deleteUser(reason: String) async throws(UserError) -> Void
    func logoutSession() async throws(UserError) -> Void
}
