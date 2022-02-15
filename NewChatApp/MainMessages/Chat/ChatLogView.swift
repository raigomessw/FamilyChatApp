//
//  ChatLogView.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-25.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

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
       
        .safeAreaInset(edge: .bottom) {
        chatBottomBar
        .background(Color(.systemBackground)
        .ignoresSafeArea())
            }
            
        }
    }
    @State private var imagePicker = false
    @State var imgData : Data = Data(count: 0)
    @State var chatLogViewModel = ChatLogViewModel(chatUser: nil)
    @State var image : UIImage?

    private var chatBottomBar: some View {
        HStack(spacing: 16) {
            
            Button {
            imagePicker.toggle()
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
        .fullScreenCover(isPresented: self.$imagePicker, onDismiss: {
            if self.imgData.count != 0 {
                vm.handleSend()
               
            }
        }) {
            ImagePicker(image: self.$image, imagePicker: self.$imagePicker)
    }
}

struct MessageView: View {
    let message: ChatMessage
    @State var imgData: Data = Data(count: 0)
    @ObservedObject private var vm = MainMessagesViewModel()

    
    var body: some View {
        VStack{
        if message.fromId == FirebaseManager.shared.auth.currentUser?.uid {
        HStack(alignment: .top, spacing: 10){
          Spacer()
            if message.photo == nil {
                HStack {
               Text(message.text)
                .clipShape(ChatBubble(myMsg: message.myMsg))
                .foregroundColor(.white)
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
            } else {
               /* Image(uiImage: UIImage(data: message.photo!) as! URL)
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width - 150, height: 150)
                    .clipShape(ChatBubble(myMsg: message.myMsg))*/
            }
          }
        } else {
            
            
    HStack(alignment: .top, spacing: 10) {
        HStack {
        Text(message.text)
        .background(Color.green)
        .clipShape(ChatBubble(myMsg: message.myMsg))
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
    
   
    var myMsg : Bool
    
    func path(in rect: CGRect) -> Path {
         
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: myMsg ?
        [.topLeft,.bottomLeft,.bottomRight] :
        [.topRight,.bottomLeft,.bottomRight], cornerRadii: CGSize(width: 10, height: 10))
        
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
}
