//
//  UserRoute.swift
//  User
//
//  Created by Youjin Lee on 12/9/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation

import Routing
import UserDomain

public enum UserRoute: String, Routable {
    case user
    case updateProfile
    case updateNote
    case terms
    case logout
    case unRegistered
    
    public var id: String { rawValue }
}
