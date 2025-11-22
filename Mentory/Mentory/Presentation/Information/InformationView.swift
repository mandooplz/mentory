//
//  InformationView.swift
//  Mentory
//
//  Created by SJS on 11/20/25.
//
import SwiftUI
import WebKit


// MARK: View
struct InformationView: View {
    private let informationURL = URL(string: "https://www.notion.so/Mentory-Information-2b11c49e815f80c5873befe3b6847f70?source=copy_link")!

    var body: some View {
        WebView(url: informationURL)
            .navigationTitle("멘토리 앱 소개")
            .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: Preview
#Preview {
    InformationView()
}
