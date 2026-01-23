//
//  LoginStatus.swift
//  Domain
//
//  Created by 김진웅 on 1/21/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Foundation

public enum LoginStatus: Equatable {
    case existingUser(nickname: String)
    case newUser(tempUser: TempUser)
    case forbidden
}
