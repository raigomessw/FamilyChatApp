//
//  CreatNewMessageView.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-25.
//

import SwiftUI
import SDWebImageSwiftUI



struct CreatNewMessageView: View {
    let didSelectNewUser: (ChatUser) -> ()// Call back
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm = CreatNewMessageViewModel()
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(vm.errorMessage)
                ForEach(vm.users) { user in
                    Button {
                        presentationMode.wrappedValue.dismiss()
                        didSelectNewUser(user)
                    } label: {
                        HStack (spacing: 16){
                            WebImage(url: URL(string: user.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 55, height: 55)
                                .clipped()
                                .cornerRadius(55)
                                .overlay(RoundedRectangle(cornerRadius: 55).stroke(Color(.label), lineWidth: 2))
                            Text(user.email)
                                .foregroundColor(Color(.label))
                            Spacer()
                        }.padding(.horizontal)
                    }
                    Divider()
                    .padding(.vertical, 8)
                        
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
