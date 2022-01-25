//
//  MainMessagesView.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-18.
//

import SwiftUI

class MainMessagesViewModel: ObservableObject {
    @Published var errorMessage = ""
    init() {
        fetchCurrentUser()
    }
    
    private func fetchCurrentUser() {
        
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else {
            self.errorMessage = "Could not find firebase uid"
            return
            
        }
        FirebaseManager.shared.firestore.collection("users").document(uid).getDocument { snapshot, error in
            if let error = error {
                self.errorMessage = "Failed to fetch current user: \(error)"
                return
            }
            self.errorMessage = "123"
            guard let data = snapshot?.data() else {
            self.errorMessage = "No data found"
            return
                
            }
           
            self.errorMessage = "Data: \(data.description)"
        }
    }
}

struct MainMessagesView: View {
    
    @State var shouldShowLogOutOptions = false
    @ObservedObject private var vm = MainMessagesViewModel()
    
    private var customNavBar: some View {
        HStack(spacing: 16){
            
            Image(systemName: "person.fill")
                .font(.system(size: 34, weight: .heavy))
            
            VStack(alignment: .leading, spacing: 4){
            Text("USERNAME")
            .font(.system(size: 24, weight: .bold))
            HStack{
                Circle()
                .foregroundColor(.green)
                .frame(width: 14, height: 14)
                Text("online")
                .font(.system(size: 12))
                .foregroundColor(Color(.lightGray))
                }
            }
            Spacer()
            Button(action: {
            shouldShowLogOutOptions.toggle()
            }, label: {
            Image(systemName: "gear")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(.label))
            })
        }
        .padding()
        .actionSheet(isPresented: $shouldShowLogOutOptions) {
            .init(title: Text("Settings"), message: Text("What do you whant to do?"), buttons: [
                .destructive(Text("Sign Out"), action: {
                    print("Handle sign out")
                }),
                //.default(Text("DEFAULT BUTTON")),
                    .cancel()
            ])
        }
    }
    var body: some View {
        NavigationView {
        
            VStack{
                Text("USER ID: \(vm.errorMessage)")
                customNavBar
                messagesView
            }
            .overlay(
            newMessageButton, alignment: .bottom)
            .navigationBarHidden(true)
            //.navigationTitle("Main Messages View")
        }
    }
    private var messagesView: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { num in
                VStack {
                    HStack(spacing: 16){
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .padding(8)
                            .overlay(RoundedRectangle(cornerRadius: 44)
                                        .stroke(Color(.label), lineWidth: 1)
                            )
                        VStack(alignment: .leading){
                        Text("Username")
                        .font(.system(size: 16, weight: .bold))
                        Text("Message sent to user")
                        .font(.system(size: 14))
                        .foregroundColor(Color(.lightGray))
                        }
                        Spacer()
                        
                        Text("22d")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    Divider()
                        .padding(.vertical, 8)
                    
                }.padding(.horizontal)
            }.padding(.bottom, 50)
        }
    }
    private var newMessageButton: some View {
        Button {
            
        } label: {
            HStack{
            Spacer()
            Text("+ New Message")
                    .font(.system(size: 16, weight: .bold))
            Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
            .background(Color.blue)
            .cornerRadius(32)
            .padding(.horizontal)
            .shadow(radius: 5)
            
        }
    }
}

struct MainMessagesView_Previews: PreviewProvider {
    static var previews: some View {
        MainMessagesView()
            .preferredColorScheme(.dark)
        MainMessagesView()
    }
}
