//
//  RecordContainerView.swift
//  Mentory
//
//  Created by JAY on 12/2/25.
//

import Foundation
import SwiftUI
import Combine


// MARK: View
struct RecordContainerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigationPath = NavigationPath()
    
    @ObservedObject var recordForm: RecordForm
    
    
    // MARK: - Body
    var body: some View {
        NavigationStack(path: $navigationPath) {
            RecordFormView(recordForm: recordForm)
                .navigationDestination(for: String.self) { value in
                    if value == "MindAnalyzer" {
                        MindAnalyzerView(recordForm.mindAnalyzer!)
                    }
                }
                .toolbar {
                    // MARK: 취소 버튼
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            if navigationPath.isEmpty {
                                // 현재 화면 = RecordFormView
                                dismiss()                   // RecordContainerView 종료
                            } else {
                                // 현재 화면 = MindAnalyzer
                                navigationPath.removeLast() // MindAnalyzerView → RecordFormView
                            }
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                    
                    // MARK: 완료 버튼 (RecordFormView에서만 보임)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if navigationPath.isEmpty {
                            // 현재 화면 = RecordFormView
                            Button {
                                recordForm.validateInput()
                                if recordForm.canProceed {
                                    Task { await recordForm.submit() }
                                }
                            } label: {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                .task {
                    for await analyzer in recordForm.$mindAnalyzer.values {
                        if let _ = analyzer {
                            navigationPath.append("MindAnalyzer")
                        }
                    }
                }
        }
    }
}
