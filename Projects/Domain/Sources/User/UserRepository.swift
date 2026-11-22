//
//  UserRepository.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

public protocol UserRepository {
    func updateNickname(_ nickname: Nickname) async throws(UserError) -> String
    func fetchUser() async throws(UserError) -> User
}
