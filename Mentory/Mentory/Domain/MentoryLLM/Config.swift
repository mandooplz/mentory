//
//  Config.swift
//  Mentory
//
//  Created by Claude Code
//

import Foundation

enum Config {
    // MARK: - Alan API Configuration

    /// Alan API Client ID (Secrets.xcconfig의 TOKEN 값)
    /// Info.plist에 ALAN_API_TOKEN = $(TOKEN) 형태로 등록되어야 합니다.
    static var alanAPIClientID: String {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "ALAN_API_TOKEN") as? String,
              !token.isEmpty else {
            fatalError("ALAN_API_TOKEN이 Info.plist에 설정되지 않았습니다. Secrets.xcconfig의 TOKEN 값을 Info.plist에 추가해주세요.")
        }
        return token
    }

    /// 사용자 이름 (Secrets.xcconfig의 NAME 값)
    /// Info.plist에 USER_NAME = $(NAME) 형태로 등록되어야 합니다.
    static var userName: String {
        guard let name = Bundle.main.object(forInfoDictionaryKey: "USER_NAME") as? String,
              !name.isEmpty else {
            fatalError("USER_NAME이 Info.plist에 설정되지 않았습니다. Secrets.xcconfig의 NAME 값을 Info.plist에 추가해주세요.")
        }
        return name
    }
}
