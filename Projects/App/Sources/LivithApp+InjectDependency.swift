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
import SearchData
import SetlistData
import SongData
import TempAuthData
import TempUserData
import UserData

extension LivithApp {
    func registerDependency() {
        DIContainer.shared.register(
            assemblers: [
                AuthDataAssembler(),
                UserDataAssembler(),
                ConcertAssembler(),
                HomeAssembler(),
                LoginAssembler(),
                SearchAssembler(),
                SetlistAssembler(),
                SongAssembler(),
                UserAssembler()
            ]
        )
    }
}
