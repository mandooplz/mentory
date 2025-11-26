//
//  CharacterType.swift
//  Values
//
//  Created by JAY on 11/26/25.
//

import Foundation

// MARK: Value
@frozen
nonisolated public enum CharacterType: String, Codable, Sendable {
    case Nangcheol
    case Gureum
    
   public var title: String {
        switch self {
        case .Nangcheol: return "냉철이가 전하는 한마디"
        case .Gureum: return "구름이가 전하는 한마디"
        }
    }
    
   public var imageName: String {
        switch self {
        case .Nangcheol: return "bunsuk"
        case .Gureum: return "gureum"
        }
    }
}

