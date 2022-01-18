//
//  SignUpViewModel.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-11.
//

import Foundation
import FirebaseAuth
import UIKit
import FirebaseStorage

class SignUpViewModel: ObservableObject { // For anexera one variabel this class must be Obeservable public
    
    var name = ""
    var email = ""
    var password = ""
    
    @Published var image = UIImage() 
    
   @Published var formInvalid = false // published used to be seen by alert in the SignUpView
    var alertText = ""
   @Published var isLoading = false // Show loading to user
    
    func signUp() {
        print("name: \(name), email: \(email), password: \(password)")
        
        if (image.size.width <= 0) { //It is one of the mandatory features to create an account "Select Picture"
            formInvalid = true
            alertText = "Select a picture!"
            return
        }
        isLoading = true
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
            
            self.uploadPhoto()
            
        }
        
    }
    
    private func uploadPhoto() {
        let filename = UUID().uuidString
        
        guard let data = image.jpegData(compressionQuality: 0.2) else {return} //Convertera img to data
        
        let newMetadata = StorageMetadata()// Indicates to the metadata what type of form is picture
        newMetadata.contentType = "image/jpeg"
        
       let reference = Storage.storage().reference(withPath: "/images/\(filename).jpg")
        
        reference.putData(data, metadata: newMetadata) { metadata, err in // data = Bytes of picture, reference to build picture
            reference.downloadURL { url, error in // If not build picture take the downloadURL
                self.isLoading = false
                print("Picture criated \(url)")
                
                
            }
            
        }
    }
    
}

