//
//  SignUpViewModel.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-11.
//

import Foundation
import FirebaseAuth

class SignUpViewModel: ObservableObject { // For anexera one variabel this class must be Obeservable public
    
    var name = ""
    var email = ""
    var password = ""
    
   @Published var formInvalid = false // published used to be seen by alert in the SignUpView
    var alertText = ""
   @Published var isLoading = false // Show loading to user
    
    func signUp() {
        isLoading = true
        print("name: \(name), email: \(email), password: \(password)")
        
        Auth.auth().createUser(withEmail: email, password: password) { // Creat acc and show err mensage
            result, err in
            guard let user = result?.user, err == nil else {
                self.formInvalid = true
                self.alertText = err!.localizedDescription
                print(err)
                self.isLoading = false
                return
            }
            self.isLoading = false
            print("User Criated \(user.uid)")
            
        }
        
        
    }
    
}

