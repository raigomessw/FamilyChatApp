//
//  MainMessagesView.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-18.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct RecentMessage: Identifiable {
    
    var id: String { documentId }
    
    let documentId: String
    let text, email: String
    let fromId, toId: String
    let profileImageUrl: String
    let timestamp: Timestamp
    
    init(documentId: String, data: [String: Any]) {
        self.documentId = documentId
        self.text = data["text"] as? String ?? ""
        self.fromId = data["fromId"] as? String ?? ""
        self.toId = data["toId"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.timestamp = data["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    }
}

class MainMessagesViewModel: ObservableObject {
    @Published var errorMessage = ""
    @Published var chatUser: ChatUser?
    @Published var isUserCurrentlyLoggedOut = false
    
    
    init() {
        DispatchQueue.main.async {
        self.isUserCurrentlyLoggedOut =
            FirebaseManager.shared.auth.currentUser?.uid == nil
        }
        fetchCurrentUser()
        
        fetchRecentMessages()
    }
    
    @Published var recentMessages = [RecentMessage]()
    
    private func fetchRecentMessages() { // Upp recent messages
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        FirebaseManager.shared.firestore
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to listen for recent messages: \(error)"
                    print(error)
                    return
                }
                querySnapshot?.documentChanges.forEach({ change in
                    let docId = change.document.documentID
                    
                    if let index = self.recentMessages.firstIndex(where: { rm in
                        return rm.documentId == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    }
                    
                    self.recentMessages.insert(.init(documentId: docId, data: change.document.data()), at: 0)
    
//                    self.recentMessages.append()
                })
            }
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
    
    @State var shouldNavigationToChatLogView = false
    @ObservedObject private var vm = MainMessagesViewModel()
    
    var body: some View {
        NavigationView {//Body view Main Message
        
            VStack{

                customNavBar
                messagesView
                
                NavigationLink("", isActive: $shouldNavigationToChatLogView) {
                    ChatLogView(chatUser: self.chatUser) // Call back to chatuser
                }
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
            ForEach(vm.recentMessages) { recentMessage in
                VStack {
                    NavigationLink {
                        Text("Destination")
                    } label: {
                        HStack(spacing: 16){
                            WebImage(url: URL(string: recentMessage.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipped()
                                .cornerRadius(64)
                                .overlay(RoundedRectangle(cornerRadius: 64)
                                .stroke(Color.black, lineWidth: 1))
                                .shadow(radius: 5)
                              
                            
                            
                            VStack(alignment: .leading, spacing: 8){
                                Text(recentMessage.email)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(.label))
                                Text(recentMessage.text)
                            .font(.system(size: 14))
                            .foregroundColor(Color(.darkGray))
                            }
                            Spacer()
                            
                            Text("22d")
                                .font(.system(size: 14, weight: .semibold))
                        }
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
        .fullScreenCover(isPresented: $shouldShowNewMesssageScreen) {//New screen to new menssage
            CreatNewMessageView(didSelectNewUser: { user in
                print(user.email)
                self.shouldNavigationToChatLogView.toggle()// Make that in new message, user klick in a user and take to chat
                self.chatUser = user
            })
            
        }
    }
    @State var chatUser: ChatUser?
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
            .preferredColorScheme(.dark)
        MainMessagesView()
    }
}
