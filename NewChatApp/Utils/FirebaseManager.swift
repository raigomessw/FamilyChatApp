//
//  FirebaseManager.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-24.
//

import Foundation
import Firebase

class FirebaseManager: NSObject {
    
    let auth: Auth
    let storage : Storage
    let firestore: Firestore
    static let shared = FirebaseManager()
    var currentUser: ChatUser?
    
    override init() {
        FirebaseApp.configure()
        
        self.auth = Auth.auth()
        self.storage = Storage.storage()
        self.firestore = Firestore.firestore()
        super.init()
    }
    
}
