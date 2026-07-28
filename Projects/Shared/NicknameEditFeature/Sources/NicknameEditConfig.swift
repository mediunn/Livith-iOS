//
//  NicknameEditConfig.swift
//  NicknameEditFeature
//
//  Created by Youjin Lee on 1/23/26.
//  Copyright © 2026 Livith. All rights reserved.
//

public enum NicknameEditConfig {
    case signup
    case update

    public var navigationTitle: String {
        switch self {
        case .signup: return "회원가입"
        case .update: return "닉네임 수정"
        }
    }

    public var title: String {
        "라이빗에서 사용할\n닉네임을 설정해 주세요"
    }

    public var submitButtonText: String {
        switch self {
        case .signup: return "다음"
        case .update: return "닉네임 변경"
        }
    }

    public var showStepIndicator: Bool {
        switch self {
        case .signup: return true
        case .update: return false
        }
    }
}
