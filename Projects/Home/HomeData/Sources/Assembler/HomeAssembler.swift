//
//  HomeAssembler.swift
//  HomeData
//
//  Created by 김진웅 on 12/29/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import DIContainer
import HomeDomain
import LivithNetwork
import Persistence

public struct HomeAssembler: DependencyAssembler {
    public init() {}
    
    public func assemble(to container: any DependencyContainer) {
        let homeService = HomeService()
        let searchService = SearchService()
        let setlistService = SetlistService()
        let concertService = ConcertService()
        let localStorage = UserDefaultsStorage()

        container.register(
            {
                HomeRepositoryImpl(
                    homeService: homeService,
                    searchService: searchService,
                    setlistService: setlistService,
                    concertService: concertService,
                    localStorage: localStorage
                )
            },
            for: HomeRepository.self)
    }
}
