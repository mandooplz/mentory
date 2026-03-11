//
//  ObjectIdentifier.swift
//  Values
//
//  Created by 김민우 on 3/12/26.
//

import Foundation


/// UUID 기반 객체 식별자를 표현하는 프로토콜입니다.
///
/// `ObjectIdentifier`를 채택하는 타입은 고유한 `UUID` 값을 보관하며,
/// 서로 다른 식별자 타입 간에도 동일한 원본 `UUID`를 유지한 채 변환할 수 있습니다.
///
/// - Note: 이 프로토콜은 객체의 메모리 주소를 나타내는 Swift 표준 라이브러리의
///   `ObjectIdentifier` 타입과 이름이 동일하므로, 사용 시 문맥을 명확히 구분하는 것이 좋습니다.
public protocol ObjectIdentifier: Sendable, Hashable, Codable {
    /// 주어진 UUID로 식별자 인스턴스를 생성합니다.
    ///
    /// - Parameter id: 식별자의 원본 UUID 값입니다.
    init(_: UUID)
    
    /// 식별자가 보관하는 고유 UUID 값입니다.
    var id: UUID { get }
}


/// `ObjectIdentifier` 채택 타입이 공통으로 사용할 수 있는 기본 구현을 제공합니다.
public extension ObjectIdentifier {
    /// 다른 식별자의 UUID 값을 사용해 현재 식별자 타입의 새 인스턴스를 생성합니다.
    ///
    /// 이를 통해 서로 다른 `ObjectIdentifier` 채택 타입 간에도
    /// 동일한 원본 UUID를 유지한 채 타입만 변환할 수 있습니다.
    ///
    /// - Parameter other: 변환의 기준이 되는 다른 식별자입니다.
    init(from other: some ObjectIdentifier) {
        self.init(other.id)
    }
}
