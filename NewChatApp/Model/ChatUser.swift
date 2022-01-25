//
//  ChatUser.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-25.
//

import Foundation

struct ChatUser {
    let uid, email, profileImageUrl: String
    
    init(data: [String: Any]) {
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        
    }
        
}
