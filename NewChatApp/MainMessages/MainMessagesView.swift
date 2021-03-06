//
//  MainMessagesView.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-18.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import FirebaseFirestoreSwift

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
    private var firestoreListener: ListenerRegistration?
    
       func fetchRecentMessages() { // Upp recent messages
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
           
           firestoreListener?.remove()
           self.recentMessages.removeAll()  //Romove all message that are obsolete
        
        firestoreListener = FirebaseManager.shared.firestore
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
                        return rm.id == docId
                    }) {
                        self.recentMessages.remove(at: index)
                    }
                    
                    do { // Try decode recent message
                        if let rm = try change.document.data(as: RecentMessage.self) {
                        self.recentMessages.insert(rm, at: 0)
                        }
                    } catch {
                        print(error)
                    }
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
            self.chatUser = try? snapshot?.data(as: ChatUser.self)
            FirebaseManager.shared.currentUser = self.chatUser
           
        }
    }
    func handleSignOut() {
        isUserCurrentlyLoggedOut.toggle()// To false
        try? FirebaseManager.shared.auth.signOut()// Logg out user
        
    }
    
}

struct MainMessagesView: View {
    
    @State var shouldShowLogOutOptions = false
    
    @State var shouldNavigateToChatLogView = false
    
    @ObservedObject private var vm = MainMessagesViewModel()
    
    private var chatLogViewModel = ChatLogViewModel(chatUser: nil)
    
    var body: some View {
        NavigationView {//Body view Main Message
        
            VStack{

                customNavBar
                messagesView
                
                NavigationLink("", isActive: $shouldNavigateToChatLogView) {
                    ChatLogView(vm: chatLogViewModel)
                }
            }
            .overlay(
            newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
    
        }
    }
    @State private var imagePicker = false
    @State var imgData: Data = Data(count: 0)
    @State var image: UIImage?
    
    private var customNavBar: some View { // User info view
        HStack(spacing: 16) {
            
            Button {
            imagePicker.toggle()
            } label: {
              if let image = self.image {// To when selected a picture Upp Picture
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .cornerRadius(64)
                    } else {
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
                    }
            }
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
        .fullScreenCover(isPresented: $imagePicker, onDismiss: nil) {
            ImagePicker(image: self.$image, imagePicker: self.$imagePicker, imgData: $imgData)
           
        }
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
                self.vm.fetchRecentMessages()//Fix the inssue that when conect from another device
            })
            
        }
    }
    private var messagesView: some View {
        ScrollView {
            ForEach(vm.recentMessages) { recentMessage in
                VStack {
                    Button {
                        let uid = FirebaseManager.shared.auth.currentUser?.uid == recentMessage.fromId ? recentMessage.toId : recentMessage.fromId
                        self.chatUser = .init(id: uid, uid: uid, email: recentMessage.email, profileImageUrl: recentMessage.profileImageUrl)
                        self.chatLogViewModel.chatUser = self.chatUser
                        self.chatLogViewModel.fetchMessages()
                        self.shouldNavigateToChatLogView.toggle()
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
                                Text(recentMessage.username)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(.label))
                            .multilineTextAlignment(.leading)
                                Text(recentMessage.text)
                            .font(.system(size: 14))
                            .foregroundColor(Color(.darkGray))
                            .multilineTextAlignment(.leading)
                            }
                            Spacer()
                            
                            Text(recentMessage.timeAgo)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(.label))
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
                self.shouldNavigateToChatLogView.toggle()// Make that in new message, user klick in a user and take to chat
                self.chatUser = user
                self.chatLogViewModel.chatUser = user
                self.chatLogViewModel.fetchMessages()
            })
            
        }
    }
    @State var chatUser: ChatUser?
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
        //.preferredColorScheme(.dark)
       // MainMessagesView()
    }
}
