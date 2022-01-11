//
//  SignInViewModel.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-11.
//

import Foundation


class SignInViewModel: ObservableObject { // For anexera one variabel this class must be Obeservable public
    var email = ""
    var password = ""
    
    func signIn() {
        print("email: \(email), password: \(password)")
    }
    
}
