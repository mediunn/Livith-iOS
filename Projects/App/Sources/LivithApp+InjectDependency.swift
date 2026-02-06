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
import NotificationData
import SearchData
import SetlistData
import SongData
import UserData
import PreferenceData

extension LivithApp {
    func registerDependency() {
        DIContainer.shared.register(
            assemblers: [
                AuthDataAssembler(),
                CommentDataAssembler(),
                ConcertDataAssembler(),
                NotificationDataAssembler(),
                SearchDataAssembler(),
                SetlistDataAssembler(),
                SongDataAssembler(),
                UserDataAssembler(),
                PreferenceDataAssembler()
            ]
        )
    }
}
