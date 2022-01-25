//
//  CreateNewMessageView.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-25.
//

import Foundation

class CreatNewMessageViewModel: ObservableObject {
    
    @Published var users = [ChatUser]()
    @Published var errorMessage = ""
    init() {
        fetchAllUsers()
    }
    
    private func fetchAllUsers() {
        FirebaseManager.shared.firestore.collection("users")
            .getDocuments { documentsSnapshot, error in
                if let error = error {
                    self.errorMessage = "Failed to fetch users: \(error)"
                    print("Failed to fetch users: \(error)")
                    return
                }
                documentsSnapshot?.documents.forEach({ snapshot in
                    let data = snapshot.data()
                    let user = ChatUser(data: data)
                    if user.uid != FirebaseManager.shared.auth.currentUser?.uid{// Take out yor self from new menssage
                    self.users.append(.init(data: data))
                    }
                   
                    
                    
                    
                })
                
                
                //self.errorMessage = "Fetch users successfully!"
            }
    }
    
}
