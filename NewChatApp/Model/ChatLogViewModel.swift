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
    let chatUser: ChatUser?
    
    init(chatUser: ChatUser?) {
        self.chatUser = chatUser
        
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
        let messageData = ["fromId": fromId, "toId": toId, "text": self.chatText, "timestamp": Timestamp()] as [String : Any]
        
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
