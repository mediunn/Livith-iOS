//
//  HomeRoute.swift
//  HomeFeature
//
//  Created by 김진웅 on 12/27/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation
import UIKit

import LivithDesignSystem
import Coordinator
import Domain

enum HomeRoute: Route {
    case home
    case interest
    case interestComplete(posterURL: URL?, title: String, prefetchedImage: UIImage?)
    case notice
    case noticeSetting
    case recommendedConcertList(concertList: [Concert])
    case preferredGenreUpdate
    case preferredAritstUpdate(selectedGenreList: [PreferredGenre])
}
