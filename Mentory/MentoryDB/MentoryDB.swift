//
//  MentoryDB.swift
//  MentoryDB
//
//  Created by 김민우 on 11/21/25.
//
import Foundation
import SwiftData
import OSLog


// MARK: Object
nonisolated actor MentoryDB: Sendable {
    // MARK: core
    init(id: ID = .shared) {
        self.id = id
    }
    
    nonisolated let logger = Logger(subsystem: "MentoryDB.MentoryDB", category: "Domain")
    
    fileprivate static let container: ModelContainer = {
        do {
            return try ModelContainer(for: Model.self)
        } catch {
            fatalError("❌ MentoryDB ModelContainer 생성 실패: \(error)")
        }
    }()
    
    
    // MARK: state
    nonisolated let id: ID
    
    func setName(_ newName: String) {
        let context = ModelContext(MentoryDB.container)
        
        // sharedUUID 에 해당하는 Model을 찾거나, 없으면 새로 생성
       let descriptor = FetchDescriptor<Model>(
         predicate: #Predicate { $0.id == self.id }
       )
        
        let model: Model
        
        do {
            if let existing = try context.fetch(descriptor).first {
                logger.debug("MentoryDB를 찾았습니다.")
                model = existing
            } else {
                logger.debug("MentoryDB가 존재하지 않습니다. 새로운 MentoryDB를 생성합니다.")
                model = Model(id: self.id, userName: newName)
            }
        } catch {
            logger.error("MentoryDB 조회 오류: \(error)")
            return
        }
        
        
        do {
            context.insert(model)
            
            model.userName = newName
            try context.save()
            logger.debug("MentoryDB에 새로운 이름 \(newName)을 저장했습니다.")
        } catch {
            logger.error("MentoryDB 저장 오류: \(error)")
            return
        }
    }
    func getName() -> String? {
        let context = ModelContext(MentoryDB.container)
        
        
        let descriptor = FetchDescriptor<Model>(
            predicate: #Predicate { $0.id == self.id }
        )
        
        do {
            guard let model = try context.fetch(descriptor).first else {
                fatalError("MentoryDB가 존재하지 않습니다.")
                return nil
            }
            
            logger.debug("MentoryDB에서 이름을 조회했습니다.")
            return model.userName
        } catch {
            logger.error("MentoryDB 조회 오류: \(error)")
            return nil
        }
    }
    
    
    // MARK: value
    @Model
    final class Model: Sendable {
        // MARK: core
        @Attribute(.unique) var id: ID
        var userName: String
        
        init(id: ID, userName: String) {
            self.id = id
            self.userName = userName
        }
    }
    
    struct ID: Sendable, Hashable {
        // MARK: core
        let rawValue: String
        
        init(_ rawValue: String) {
            self.rawValue = rawValue
        }
        
        static let shared = ID("MentoryDB.UniqueKey.shared")
    }
}
