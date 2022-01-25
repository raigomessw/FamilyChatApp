//
//  CreatNewMessageView.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-25.
//

import SwiftUI




struct CreatNewMessageView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                ForEach(0..<10) { num in
                    Text("New user")
                }
            }.navigationTitle("New Message")
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button {
                            presentationMode.wrappedValue
                                .dismiss()
                        } label : {
                            Text("Cancel")
                        }
                    }
                    
                }
        }
    }
}

struct CreatNewMessageView_Previews: PreviewProvider {
    static var previews: some View {
        //CreatNewMessageView()
        MainMessagesView()
    }
}
