//
//  ChatLogViewModel.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-25.
//

import Foundation
import Firebase



class ChatLogViewModel: ObservableObject {
    @Published var count = 0
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [ChatMessage]()
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        fetchMessages()
        
    }
    
    struct ChatMessage: Identifiable {
        
        var id: String { documentId }
        
        let documentId: String
        let fromId, toId, text: String
        
        init(documentId: String, data: [String: Any]) {
            self.documentId = documentId
            self.fromId = data[FirebaseConstants.fromId] as? String ?? ""
            self.toId = data[FirebaseConstants.toId] as? String ?? ""
            self.text = data[FirebaseConstants.text] as? String ?? ""
        }
    }
    
    private func fetchMessages () {
        guard let fromId = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let toId = chatUser?.uid else { return }
        
        FirebaseManager.shared.firestore.collection("messages").document(fromId)
            .collection(toId)
            .order(by: "timestamp")
            .addSnapshotListener { querySnapshot, error in //" getDocuments" Would fetch everything in this point time
                if let error = error {
                    self.errorMessage = "Failed to listen for messages: \(error)"
                    print(error)
                    return
                }
                
                querySnapshot?.documentChanges.forEach({ change in// Fix dubble message
                    if change.type == .added {
                        let data = change.document.data()
                        self.chatMessages.append(.init(documentId: change.document.documentID, data: data)) // Construction message
                        
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
             FirebaseManager.shared.firestore.collection("messages")
            .document(fromId)
            .collection(toId)
            .document()
        
        let messageData = [FirebaseConstants.fromId: fromId, FirebaseConstants.toId: toId, FirebaseConstants.text: self.chatText, "timestamp": Timestamp()] as [String : Any]
        
        document.setData(messageData) { error in
            if let error = error {
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
        
        recipientMessageDocument.setData(messageData) { error in
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
            .collection("recent_messages")
            .document(uid)
            .collection("messages")
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

        /*guard let currentUser =
                FirebaseManager.shared.currentUser else {return }
            let recipientRecentMessageDictionary = [
                FirebaseConstants.timestamp: Timestamp(),
                FirebaseConstants.text: self.chatText,
                FirebaseConstants.fromId: uid,
                FirebaseConstants.toId: toId,
                FirebaseConstants.profileImageUrl: currentUser.profileImageUrl,
                FirebaseConstants.email: currentUser.email
            ] as [String : Any]

            FirebaseManager.shared.firestore
                .collection("recent_messages")
                .document(toId)
                .collection("messages")
                .document(currentUser.uid)
                .setData(recipientRecentMessageDictionary) { error in
                    if let error = error {
                        print("Failed to save recipient recent message: \(error)")
                        return
                    }
                }*/
        }

    }
