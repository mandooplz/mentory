//
//  SignUpForm.swift
//  SampleCounter
//
//  Created by 김민우 on 11/12/25.
//
import Combine


// MARK: Object
@MainActor
final class SignUpForm: Sendable, ObservableObject {
    // MARK: core
    init(owner: SignInForm) {
        self.owner = owner
    }
    
    
    // MARK: state
    nonisolated let owner: SignInForm
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordCheck: String = ""
    
    
    // MARK: action
    func signUp() {
        // mutate
        // 로그인된 상태로의 변화
        let signInForm = owner
        let sampleCounter = owner.owner
        
        signInForm.signUpForm = nil
        
        sampleCounter.signInForm = nil
        sampleCounter.isSigned = true
        sampleCounter.newCounter = NewCounter(owner: sampleCounter)
    }
}
