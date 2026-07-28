//
//  InterestConcertListNextToken.swift
//  UserData
//
//  Created by 김진웅 on 5/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Domain

struct InterestConcertListNextToken: NextToken {
    let cursorDate: String
    let id: Int
}
