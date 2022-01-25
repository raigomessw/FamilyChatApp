//
//  NewChatAppApp.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-11.
//

import SwiftUI
import Firebase

@main
struct NewChatAppApp: App {
    /*init() {
        FirebaseApp.configure()
    }*/
    
    var body: some Scene {
        WindowGroup {
           //LoginView()
            MainMessagesView()
        }
    }
}
