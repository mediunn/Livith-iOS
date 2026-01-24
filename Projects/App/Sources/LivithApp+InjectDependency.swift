//
//  LivithApp+InjectDependency.swift
//  Livith-iOS
//
//  Created by Youjin Lee on 11/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import AuthData
import CommentData
import ConcertData
import SearchData
import SetlistData
import SongData
import UserData

extension LivithApp {
    func registerDependency() {
        DIContainer.shared.register(
            assemblers: [
                AuthDataAssembler(),
                CommentDataAssembler(),
                ConcertDataAssembler(),
                SearchDataAssembler(),
                SetlistDataAssembler(),
                SongDataAssembler(),
                UserDataAssembler()
            ]
        )
    }
}
