//
//  ChatLogViewModel.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-25.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?
    let fromId, toId, text: String
    let myMsg: Bool
    var msgPhoto: Data?
    let timestamp: Date
}

class ChatLogViewModel: ObservableObject {
    @Published var count = 0
    
    @Published var chatText = ""
    @Published var msgPhoto : Data = Data(count: 0)
    @Published var errorMessage = ""
    @Published var chatMessages = [ChatMessage]()
    var chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        fetchMessages()
        
    }
    
    var firestoreListener: ListenerRegistration?

       func fetchMessages() {
    
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = chatUser?.uid else { return }
        firestoreListener?.remove()
           chatMessages.removeAll()
        
        firestoreListener = FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .order(by: FirebaseConstants.timestamp)
            .addSnapshotListener { querySnapshot, error in //" getDocuments" Would fetch everything in this point time
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in //Fix dubble message
                    if change.type == .added {
                        do {
                            if let cm = try change.document.data(as: ChatMessage.self) {
                                self.chatMessages.append(cm)
                                print("Appending chatMessage in ChatLogView: \(Date())")
                            }
                        } catch {
                            print("Failed to decode message: \(error)")
                        }
                    }
                })
                
                DispatchQueue.main.async {
                self.count += 1 // Make Scroll view down automat when start convesation
                }
                
    }
}
    

    
    func handleSend() { // Save data in firebase// Users messages
      print(chatText)
        
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = chatUser?.uid else { return }
        
        let document =
        FirebaseManager.shared.firestore.collection(FirebaseConstants.messages)
            .document(fromId)
            .collection(toId)
            .document()
        
        let msg = ChatMessage(id: nil, fromId: fromId, toId: toId, text: chatText, myMsg: true, timestamp: Date())

        try? document.setData(from: msg) { error in
            if let error = error {
                print(error)
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            print("Successfully saved current user sending message")
            self.persistRecentMessage()
            self.chatText = "" // Make the text disappear
            self.count += 1 // Make Scroll view down automat when send message
            
        }
        let recipientMessageDocument =
             FirebaseManager.shared.firestore.collection("messages")
            .document(toId)
            .collection(fromId)
            .document()
        
        try? recipientMessageDocument.setData(from: msg) { error in
            if let error = error {
                self.errorMessage = "Failed to save message into Firestore: \(error)"
                return
            }
            
        }
    }
    
    private func persistRecentMessage() {
            guard let chatUser = chatUser else { return }
        
        

            guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
                return }
            guard let toId = self.chatUser?.uid else { return }

            let document = FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(uid)
            .collection(FirebaseConstants.messages)
            .document(toId)

            let data = [
                FirebaseConstants.timestamp: Timestamp(),
                FirebaseConstants.text: self.chatText,
                FirebaseConstants.fromId: uid,
                FirebaseConstants.toId: toId,
                FirebaseConstants.profileImageUrl: chatUser.profileImageUrl,
                FirebaseConstants.email: chatUser.email
            ] as [String : Any]

            document.setData(data) { error in
                if let error = error {
                    self.errorMessage = "Failed to save recent message: \(error)"
                    print("Failed to save recent message: \(error)")
                    return
                }
            }

        guard let currentUser = FirebaseManager.shared.currentUser else { return }
        let recipientRecentMessageDictionary = [
            FirebaseConstants.timestamp: Timestamp(),
            FirebaseConstants.text: self.chatText,
            FirebaseConstants.fromId: uid,
            FirebaseConstants.toId: toId,
            FirebaseConstants.profileImageUrl: currentUser.profileImageUrl,
            FirebaseConstants.email: currentUser.email
        ] as [String : Any]
        
        FirebaseManager.shared.firestore
            .collection(FirebaseConstants.recentMessages)
            .document(toId)
            .collection(FirebaseConstants.messages)
            .document(currentUser.uid)
            .setData(recipientRecentMessageDictionary) { error in
                if let error = error {
                    print("Failed to save recipient recent message: \(error)")
                    return
                }
            }
        }

    }
