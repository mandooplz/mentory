//
//  StatisticsBoard.swift
//  Mentory
//
//  Created by 김민우 on 2/25/26.
//
import Foundation
import Combine
import Values
import MentoryDBAdapter


// MARK: object
@MainActor
public final class StatisticsBoard: ObservableObject {
    // MARK: core
    init(owner: MentoryiOS) {
        self.owner = owner
    }
    
    
    // MARK: state
    weak var owner: MentoryiOS?
    
    @Published public var isLoading: Bool = false
    
    @Published public var allRecords: [RecordData] = []
    @Published public var selectedMonth: Date = Date() {
        didSet {
            // 이게 무슨 코드지?
            if oldValue != selectedMonth {
                selectedDate = nil
            }
        }
    }

    @Published public var selectedDate: Date? = nil
    @Published public var errorMessage: String? = nil
    
    
    // MARK: action
    // MentoryDB에서 기록들을 load
    public func initRecords() {
        // capture
        let mentoryDB = self.owner!.mentoryDB

        
        // process
        Task {
            do {
                let records = try await mentoryDB.getRecords()
                
                // mutate
                self.allRecords = records
                self.isLoading = false
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
        
        // mutate
    }
}
