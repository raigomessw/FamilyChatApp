//
//  MainMessagesView.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-18.
//

import SwiftUI
import SDWebImageSwiftUI

class MainMessagesViewModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isUserCurrentlyLoggedOut = false
    
    
    init() {
        DispatchQueue.main.async {
        self.isUserCurrentlyLoggedOut = true
        FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()
    }
    
       func fetchCurrentUser() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
            
        }
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                return
            }
           
            guard let data = snapshot?.data() else {
            self.errorMessage = "No data found"
            return
                
            }
            self.chatUser = .init(data: data)
           
        }
    }
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()// To false
        try? FirebaseManager.shared.auth.signOut()// Logg out user
        
    }
    
}

struct MainMessagesView: View {
    
    @State var shouldShowLogOutOptions = false
    @ObservedObject private var vm = MainMessagesViewModel()
    
    var body: some View {
        NavigationView {//Body view Main Message
        
            VStack{
                //Text("USER : \(vm.chatUser?.uid ?? "")")
                customNavBar
                messagesView
            }
            .overlay(
            newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
    
        }
    }
    
    private var customNavBar: some View { // User info view
        HStack(spacing: 16) {
            
            WebImage(url: URL(string:
             vm.chatUser?.profileImageUrl ?? ""))
            .resizable()
            .frame(width: 50, height: 50)
            .clipped()
            .cornerRadius(50)
            .overlay(RoundedRectangle(cornerRadius: 44)
                        .stroke(Color(.label), lineWidth: 1)
            )
            .shadow(radius: 5)
            
            VStack(alignment: .leading, spacing: 4){
                let email = vm.chatUser?.email.replacingOccurrences(of: "@gmail.com", with: "") ?? ""
                Text(email)
            .font(.system(size: 24, weight: .bold))
            HStack{
                Circle()
                .foregroundColor(.green)
                .frame(width: 14, height: 14)
                Text("online")
                .font(.system(size: 12))
                .foregroundColor(Color(.lightGray))
                }
            }
            Spacer()
            Button(action: {
            shouldShowLogOutOptions.toggle()
            }, label: {
            Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            })
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you whant to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    print("Handle sign out")
                    vm.handleSignOut()
                }),
                    .cancel()
            ])
        }
        .fullScreenCover(isPresented: $vm.isUserCurrentlyLoggedOut, onDismiss: nil) {// Log Out Screen
            LoginView(didCompleteLoginProcess: {
                self.vm.isUserCurrentlyLoggedOut = false
                self.vm.fetchCurrentUser() //Upp user from main
            })
            
        }
    }
    private var messagesView: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { num in
                VStack {
                    HStack(spacing: 16){
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .padding(8)
                            .overlay(RoundedRectangle(cornerRadius: 44)
                                        .stroke(Color(.label), lineWidth: 1)
                            )
                        VStack(alignment: .leading){
                        Text("Username")
                        .font(.system(size: 16, weight: .bold))
                        Text("Message sent to user")
                        .font(.system(size: 14))
                        .foregroundColor(Color(.lightGray))
                        }
                        Spacer()
                        
                        Text("22d")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    Divider()
                        .padding(.vertical, 8)
                    
                }.padding(.horizontal)
            }.padding(.bottom, 50)
        }
    }
    
    @State var shouldShowNewMesssageScreen = false
    private var newMessageButton: some View {
        Button {
            shouldShowNewMesssageScreen.toggle()
            
        } label: {
            HStack{
            Spacer()
            Text("+ New Message")
                    .font(.system(size: 16, weight: .bold))
            Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
            .background(Color.blue)
            .cornerRadius(32)
            .padding(.horizontal)
            .shadow(radius: 5)
            
        }
        .fullScreenCover(isPresented: $shouldShowNewMesssageScreen) {
            CreatNewMessageView()
            
        }
    }
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
            .preferredColorScheme(.dark)
        MainMessagesView()
    }
}