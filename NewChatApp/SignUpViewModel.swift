//
//  SignUpViewModel.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-11.
//

import Foundation

class SignUpViewModel: ObservableObject { // For anexera one variabel this class must be Obeservable public
    
    var name = ""
    var email = ""
    var password = ""
    
    func signUp() {
        print("name: \(name), email: \(email), password: \(password)")
    }
    
}

