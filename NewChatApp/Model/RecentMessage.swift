//
//  RecentMessage.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-29.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct RecentMessage: Codable, Identifiable {
    
    @DocumentID var id: String?
    let text, email: String
    let fromId, toId: String
    let profileImageUrl: String
    let timestamp: Date
    
    var username: String { // Change the name email
        email.components(separatedBy: "@").first ?? email
    }
    var timeAgo: String { // Change timeago in the rencentMessage
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

