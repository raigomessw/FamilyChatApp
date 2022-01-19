//
//  SignInViewModel.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-11.
//

import Foundation
import Firebase

class FirebaseManager: NSObject {
    let auth: Auth
    static let shared = FirebaseManager()
    
    override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        super.init()
    }
}



class SignInViewModel: ObservableObject { // For anexera one variabel this class must be Obeservable public
    var email = ""
    var password = ""
    
    @Published var formInvalid = false // published used to be seen by alert in the SignUpView
     var alertText = ""
    @Published var isLoading = false // Show loading to user
    
    
    func signIn() {
        print("email: \(email), password: \(password)")
        
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { // Login to user and show err mensage
            result, err in
            guard let user = result?.user, err == nil else {
                self.formInvalid = true
                self.alertText = err!.localizedDescription
                print(err)
                self.isLoading = false
                return
            }
            self.isLoading = false
            print("User logged \(user.uid)")
            
        }
    }
    
}
