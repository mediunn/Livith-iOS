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
import TempConcertData
import TempSearchData
import TempSetlistData
import TempSongData
import UserData

extension LivithApp {
    func registerDependency() {
        DIContainer.shared.register(
            assemblers: [
                ConcertAssembler(),
                ConcertDataAssembler(),
                HomeAssembler(),
                LoginAssembler(),
                SearchDataAssembler(),
                SetlistDataAssembler(),
                SongDataAssembler(),
                UserAssembler()
            ]
        )
    }
}
