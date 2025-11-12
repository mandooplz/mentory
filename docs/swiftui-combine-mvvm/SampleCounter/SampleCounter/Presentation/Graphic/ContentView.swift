//
//  ContentView.swift
//  SampleCounter
//
//  Created by 김민우 on 11/12/25.
//
import SwiftUI

struct ContentView: View {
    // MARK: core
    @ObservedObject var app: SampleCounter
    
    
    // MARK: body
    var body: some View {
        VStack {
            Text("숫자 : \(app.number)")
            
            Button("+") { app.increment() }
            Button("-") { app.decrement() }
            
            Button("SetUp") { app.setUpForm() }
            
            if let form = app.signInForm {
                NavigationLink {
                    SignInFormView(form)
                } label: {
                    Text("로그인으로 넘어갑니다.")
                }
            }
            
            if app.isSigned {
                Text("로그인된 상태입니다.")
            } else {
                Text("로그아웃된 상태입니다.")
            }
        }
        .padding()
        .font(.largeTitle)
    }
}

#Preview {
    ContentView(app: SampleCounter())
}
