//
//  ConcertRoute.swift
//  ConcertFeature
//
//  Created by Youjin Lee on 12/31/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import ConcertDomain
import DSKit

public enum ConcertRoute: Route {
    case detail(concertID: Int)
    case safari(URL)
    case ticketSafari(URL)
    case merchandiseDetail([ConcertMerchandise])
}
