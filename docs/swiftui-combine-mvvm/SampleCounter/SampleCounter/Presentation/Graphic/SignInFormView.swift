//
//  SignInFormView.swift
//  SampleCounter
//
//  Created by 김민우 on 11/12/25.
//
import SwiftUI


// MARK: View
struct SignInFormView: View {
    @ObservedObject var signInForm: SignInForm
    init(_ signInForm: SignInForm) {
        self.signInForm = signInForm
    }
    
    var body: some View {
        VStack {
            TextField("아이디를 입력하세요", text: $signInForm.email)
            TextField("비밀번호를 입력하세요", text: $signInForm.email)
            
            Button("제출하기") {
                signInForm.submit()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}


#Preview {
    let app = SampleCounter()
    
    SignInFormView(SignInForm(owner: app))
}
