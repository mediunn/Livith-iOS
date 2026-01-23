//
//  LivithApp+InjectDependency.swift
//  Livith-iOS
//
//  Created by Youjin Lee on 11/8/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import ConcertData
import HomeData
import LoginData
import TempAuthData
import TempConcertData
import TempSearchData
import TempSetlistData
import TempSongData
import TempUserData

extension LivithApp {
    func registerDependency() {
        DIContainer.shared.register(
            assemblers: [
                AuthDataAssembler(),
                ConcertAssembler(),
                ConcertDataAssembler(),
                HomeAssembler(),
                LoginAssembler(),
                SearchDataAssembler(),
                SetlistDataAssembler(),
                SongDataAssembler(),
                UserDataAssembler()
            ]
        )
    }
}
