//
//  ConcertListNextToken.swift
//  ConcertData
//
//  Created by 김진웅 on 5/1/26.
//  Copyright © 2026 Livith. All rights reserved.
//

import Domain

struct ConcertListNextToken: NextToken {
    let cursor: Int
}
