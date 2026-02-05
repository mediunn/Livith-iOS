//
//  AuthMapper.swift
//  Data
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

import Domain
import LivithNetwork

struct AuthMapper {
    func toDomain(from response: DTO.Response.CheckNicknameDuplicate) -> Bool {
        return response.available
    }
    
    func toDomain(from response: DTO.Response.FetchUserInfo) -> User {
        return User(
            id: response.id,
            interestConcertID: response.interestConcertID,
            provider: response.provider,
            providerID: response.providerID,
            email: response.email,
            nickname: response.nickname,
            authority: UserAuthority(deviceNotification: true, marketingConsent: response.marketingConsent)
        )
    }

    func toDomain(
        from response: DTO.Response.FetchUserInfo,
        notificationSettings: DTO.Response.FetchNotificationSettings
    ) -> User {
        return User(
            id: response.id,
            interestConcertID: response.interestConcertID,
            provider: response.provider,
            providerID: response.providerID,
            email: response.email,
            nickname: response.nickname,
            authority: UserAuthority(
                deviceNotification: true,
                marketingConsent: response.marketingConsent,
                benefitNotification: notificationSettings.benefitAlert,
                nightNotification: notificationSettings.nightAlert,
                ticketSchedule: notificationSettings.ticketAlert,
                concertInfoUpdate: notificationSettings.infoAlert,
                favoriteArtistConcert: notificationSettings.interestAlert,
                preferenceBasedConcert: notificationSettings.recommendAlert
            )
        )
    }
}
