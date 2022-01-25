//
//  ContentView.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-11.
//

import SwiftUI

struct LoginView: View {
    
    let didCompleteLoginProcess: () -> ()
    
  // @StateObject help to see the object into the class. All info av logic code stay into class
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    @State var loginStatusMessage = ""
    @State private var shouldShowImagePicker = false
    @State var image: UIImage?
    
    var body: some View {
        NavigationView{
            ScrollView {
                VStack(spacing: 12){
                    Image("logo")
                    .resizable()
                    .frame(width: 150.0, height: 150.0)
                    .scaledToFit()
                    .padding()
                    Text("Family Chat ")
                    .padding()
                    
                    Picker(selection: $isLoginMode, label: Text("Picker here")) {
                        Text("Login")
                            .tag(true)
                        Text("Creat Account")
                            .tag(false)//Default tag
                    }.pickerStyle(SegmentedPickerStyle())//Show picker sigmented
                      
                    if !isLoginMode {// Swith to create ou login
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: {
                            
                            VStack{
                                if let image = self.image {// To when selected a picture Upp Picture
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                        .cornerRadius(64)
                                } else {
                                Image(systemName: "person.fill")
                                .font(.system(size: 64))
                                .padding()
                                .foregroundColor(Color(.label))
                                
                                }
                                    
                            }
                            .overlay(RoundedRectangle(cornerRadius: 64).stroke(Color.black, lineWidth: 3))
                        }
                    }
                
                    Group {
                    TextField("Email:", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)//Turn off Capslock
                        SecureField("Password:", text: $password)
                    }
                    .autocapitalization(.none)//Turn off Capslock
                    .disableAutocorrection(false)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(24.0)
                    .overlay(RoundedRectangle(cornerRadius: 24.0)
                    .strokeBorder(Color(UIColor.separator),style: StrokeStyle(lineWidth: 1.0)))
                        .padding(.bottom, 20)
                    
                    Button{ //Login Button
                        handleAction()  
                    } label: {
                        HStack{
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.white)
                                .cornerRadius(24.0)
                        }.background(Color.blue)
                    }
                    Text(self.loginStatusMessage)
                        .foregroundColor(.red)
                }
                .padding()
            }
            .navigationBarTitle(isLoginMode ? "Login" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05)))
          }
        .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: nil) {
            ImagePicker(image: $image )
           
        }
        
       }
    
    private func handleAction() {// Func to creat or login
        if isLoginMode {
            print("Shoud log into Firebase with existenting credentials")
            loginUser()
        }else {
            createNewAccount()
            print("Register a new account inside of Firebase Auth and then store in Storage somehow..")
        }
      }
    private func loginUser() { // Func to loggin
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) {
            result, err in
            if let err = err {
                print("Failed to login user:", err)
                self.loginStatusMessage = "Failed to login user: \(err)"
                return
            }
            print("Successfully logged in as user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully logged is as user: \(result?.user.uid ?? "")"
            self.didCompleteLoginProcess()
                
            
            
        }
    }
    
    private func createNewAccount() { // Func to create acc
        
        if self.image == nil {
            self.loginStatusMessage = "You must select an avatar image!"
            return
        }
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) {
            result, err in
            if let err = err {
                print("Failed to create user:", err)
                self.loginStatusMessage = "Failed to create user: \(err)"
                return
            }
            print("Successfully created user: \(result?.user.uid ?? "")")
            self.loginStatusMessage = "Successfully created user: \(result?.user.uid ?? "")"
            persistImageToStorage()
        }
        
      }
    
    private func persistImageToStorage() {
       // let filename = UUID().uuidString
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid
        else { return }
        
        let ref = FirebaseManager.shared.storage.reference(withPath: uid)
        guard let imageData = self.image?.jpegData(compressionQuality: 0.5) else {return} //Convertera img to data
        ref.putData(imageData, metadata: nil) { metadata, err in
            if let err = err {
                self.loginStatusMessage = "Failed to push image to Storage: \(err)"
                return
            }
            
            ref.downloadURL { url, error in // If not build picture take the downloadURL
                if let err = err {
                    self.loginStatusMessage = "Failed to retrive downloadURL: \(err)"
                    return
                }
                
                self.loginStatusMessage = "Successfully stored image with url: \(url?.absoluteString ?? "")"
                
                guard let url = url else { return }
                self.storeUserInformation(imageProfileUrl: url)
                
            
        }
      }
    }
    
    private func storeUserInformation(imageProfileUrl: URL) { //Creat user in fireStore with info
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        let userData = ["email": self.email, "uid": uid, "profileImageUrl": imageProfileUrl.absoluteString]
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { err in
                if let err = err {
                    print(err)
                    self.loginStatusMessage = "\(err)"
                    return
                }

                print("Success")
                self.didCompleteLoginProcess()
            }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(didCompleteLoginProcess: {
            
        })
    }
}
