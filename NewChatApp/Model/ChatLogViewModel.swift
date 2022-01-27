//
//  ChatLogViewModel.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-25.
//

import Foundation
import Firebase



class ChatLogViewModel: ObservableObject {
    
    @Published var chatText = ""
    @Published var errorMessage = ""
    @Published var chatMessages = [ChatMessage]()
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        fetchMessages()
        
    }
    struct FirebaseConstants {
        static let fromId = "fromId"
        static let toId = "toId"
        static let text = "text"
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
            
            self.chatText = "" // Make the text disappear
            
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
}
