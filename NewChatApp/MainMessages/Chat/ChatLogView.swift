//
//  ChatLogView.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-25.
//

import SwiftUI
import Firebase


struct ChatLogView: View { //Struct chat view
    
    @ObservedObject var vm: ChatLogViewModel

    var body: some View {
        ZStack {
            messagesView
            Text(vm.errorMessage)
        }
        .navigationTitle(vm.chatUser?.email ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                vm.firestoreListener?.remove()
            }
       }
    
    static let emptyScrollToString = "Empty"


    private var messagesView: some View {
        VStack{
            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack {
                        ForEach(vm.chatMessages) { message in
                        MessageView(message: message)
                            
                        }
                HStack{ Spacer() }
                .id(ChatLogView.emptyScrollToString)
                }
                .onReceive(vm.$count) { _ in
                    withAnimation(.easeOut(duration: 0.5)) {
                        scrollViewProxy.scrollTo(ChatLogView.emptyScrollToString, anchor: .bottom)
                    }
                }
                    
            }
        }
        .background(Color(.init(white: 0.95, alpha: 1)))
        .safeAreaInset(edge: .bottom) {
        chatBottomBar
        .background(Color(.systemBackground)
        .ignoresSafeArea())
            }
            
        }
    }
    @State private var shouldShowImagePicker = false
    @State var image: UIImage?
    @State var imgData : Data = Data(count: 0)

    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            
            Button {
            shouldShowImagePicker.toggle()
            } label: {
            Image(systemName: "paperclip.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            }
            ZStack {
                DescriptionPlaceholder()
                TextEditor(text: $vm.chatText)
                    .opacity(vm.chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)

            Button {
                vm.handleSend()

            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 20))
                    //Rotating the image
                    .rotationEffect(.init(degrees: 45))
                    .padding(.all)
                    .background(Color.black.opacity(0.07))
                    .clipShape(Circle())
                
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 9)
        .fullScreenCover(isPresented: $shouldShowImagePicker, onDismiss: {
            if imgData.count != 0 {
                vm.chatText
            }
        }) {
            ImagePicker(image: $image, imgData: $imgData)
        }
    }
}

struct MessageView: View {
    let message: ChatMessage
    @State var image: UIImage?
    @State var imgData : Data = Data(count: 0)

    
    var body: some View {
        VStack{
        if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
        HStack {
          Spacer()
          HStack {
           Text(message.text)
            .background(Color.blue)
            .clipShape(ChatBubble(mymsg: true))
            .foregroundColor(.white)
            }
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
                }
                        
        } else {
    HStack {
        HStack {
        Text(message.text)
        .background(Color.green)
        .clipShape(ChatBubble(mymsg: true))
        .foregroundColor(.black)
        }
        .padding()
        .background(Color.green)
        .cornerRadius(8)
        Spacer()
    }
}
}
    .padding(.horizontal)
    .padding(.top, 8)
    }
 }

struct ChatBubble : Shape {
    
   
    var mymsg : Bool
    
    func path(in rect: CGRect) -> Path {
         
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.topLeft,.topRight,mymsg ? .bottomLeft: .bottomRight], cornerRadii: CGSize(width: 10, height: 10))
        
        return Path(path.cgPath)
    }
}


private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Message")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}

struct ChatLogView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            //ChatLogView(chatUser: .init(data: ["uid": "3A85OfVrNpVBfj4g1MIer3JgCWj1", "email": "rai@gmail.com"]))
            MainMessagesView()
        }
       
    }
}
