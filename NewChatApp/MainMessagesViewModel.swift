//
//  MainMessagesViewModel.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-18.
//

import Foundation



class MainMessagesViewModel: ObservableObject {
    init() {
        fetchCurrentUser()
    }
    
    private func fetchCurrentUser() {
        FirebaseManager.shared.auth.currentUser?.uid
    }
}
