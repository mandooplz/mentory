//
//  MentoryCharacter.swift
//  Mentory
//
//  Created by 김민우 on 12/1/25.
//
import Foundation


// MARK: Value
@frozen nonisolated
public enum MentoryCharacter: String, Sendable, Hashable, CaseIterable, Codable {
    // MARK: core
    case cool // 냉철이
    case warm // 구름이
    
    public static var random: MentoryCharacter {
        Bool.random() ? .cool : .warm
    }
    
    
    // MARK: operator
    public var title: String {
        switch self {
        case .cool: return "명료한 시선의 한마디"
        case .warm: return "다정한 시선의 한마디"
        }
    }
    
    public var imageName: String {
        switch self {
        case .cool: return "cool"
        case .warm: return "warm"
        }
    }
    
    public var displayName: String {
        switch self {
        case .cool: return "명료한 시선"
        case .warm: return "다정한 시선"
        }
    }

    public var description: String {
        switch self {
        case .cool: return "조금 떨어져 바라보며 상황과 감정을 또렷하게 정리해드릴게요."
        case .warm: return "마음을 먼저 살피며 부드럽고 따뜻한 언어로 되짚어드릴게요."
        }
    }
    
    public var messageDescription: String {
        switch self {
        case .cool:
            return "상황을 한 걸음 떨어져 바라보며 감정의 흐름과 원인을 또렷하게 정리해줘. 과장된 위로보다 명료한 해석을 우선하고, 사용자가 스스로 상황을 이해할 수 있도록 짧고 단정한 문장으로 설명해줘. 음성이 첨부된 경우 말투와 속도에서 드러나는 긴장감이나 안정감을 함께 반영하고, 이미지가 첨부된 경우 공간과 분위기가 감정에 준 영향을 차분하게 짚어줘."
        case .warm:
            return "따뜻하고 안정적인 톤으로 감정의 결을 먼저 살펴줘. 사용자가 왜 그런 감정을 느꼈는지 상황적 맥락을 부드럽게 풀어주고, 충분히 그럴 수 있다는 안도감을 자연스럽게 담아줘. 음성이 첨부된 경우 말투와 호흡에 담긴 감정을 다정하게 짚어주고, 이미지가 첨부된 경우 장면의 분위기와 감정의 연결을 섬세하게 설명해줘."
        }
    }
    
    // 오늘의 한마디를 가져오기 위한 질문
    public var question: String {
        switch self {
        case .cool:
            return "오늘을 차분히 돌아보게 하는 짧은 문장을 한국어로 한 문장만 작성해줘. 단정하고 또렷한 어조로 말하고, 과장된 표현이나 이모티콘은 넣지 마."
        case .warm:
            return "오늘의 마음을 다독여주는 짧은 문장을 한국어로 한 문장만 작성해줘. 부드럽고 따뜻한 어조로 말하고, 과장된 표현이나 이모티콘은 넣지 마."
        }
    }
}
