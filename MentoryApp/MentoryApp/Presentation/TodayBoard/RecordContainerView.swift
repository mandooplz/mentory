//
//  RecordContainerView.swift
//  Mentory
//
//  Created by JAY on 12/2/25.
//
import Foundation
import SwiftUI
import Combine
import MentoryCore
import Values


// MARK: View
struct RecordContainerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var recordForm: RecordForm
    
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            RecordFormView(recordForm: recordForm)
                .navigationDestination(item: $recordForm.mindAnalyzer) { mindAnalyzer in
                    MindAnalyzerView(mindAnalyzer: mindAnalyzer)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(recordForm.mindAnalyzer == nil ? "닫기" : "뒤로") {
                            if recordForm.mindAnalyzer == nil {
                                recordForm.finish()
                                dismiss()
                            } else {
                                recordForm.mindAnalyzer = nil
                            }
                        }
                    }

                    ToolbarItem(placement: .principal) {
                        Text(toolbarTitle)
                            .mentoryCaption()
                            .foregroundStyle(.secondary)
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        if recordForm.mindAnalyzer == nil {
                            Button {
                                Task {
                                    recordForm.validateInput()
                                    await recordForm.submit()
                                }
                            } label: {
                                Text("정리 보기")
                            }
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .foregroundStyle(recordForm.canProceed ? Color.mentoryAccentPrimary : .secondary)
                            .disabled(!recordForm.canProceed)
                        }
                    }
                }
                .toolbarBackground(.hidden, for: .navigationBar)
        }
    }

    private var toolbarTitle: String {
        let relativeDay = recordForm.targetDate.relativeDay(from: .now)
        return relativeDay == .unknown ? recordForm.targetDate.formatted() : "\(relativeDay.rawValue) 기록"
    }
}



#Preview {
    
}
