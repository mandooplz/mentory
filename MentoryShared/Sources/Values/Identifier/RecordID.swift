//
//  RecordID.swift
//  Values
//
//  Created by 김민우 on 3/12/26.
//

import Foundation


// MARK: value
public nonisolated struct RecordID: ObjectIdentifier {
    // MARK: core
    public nonisolated let id: UUID
    
    public init(_ id: UUID) {
        self.id = id
    }
}
