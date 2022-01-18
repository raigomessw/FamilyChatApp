//
//  SignUpView.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-11.
//

import SwiftUI

struct SignUpView: View {
    @StateObject var viewModel = SignUpViewModel()//State of Obeject help to see the object into the class. All info av logic code stay into class SignViewModel
    
    @State var isShowPhotoLibary = false
     
     var body: some View {
         
     
         VStack{
             
             Button(action: {
                 isShowPhotoLibary = true
             }, label: {
                 if viewModel.image.size.width > 0 { // Show Pincture
                     Image(uiImage: viewModel.image)
                         .resizable()
                         .scaledToFill()
                         .frame(width: 130, height: 130)
                         .clipShape(Circle())
                         .overlay(Circle().stroke(Color("GreenColor"),lineWidth: 4))
                         .shadow(radius: 7)
                     
                 } else {
                 Text("Picture")//Default Picture
                     .frame(width: 130, height: 130)
                     .padding()
                     .background(Color("GreenColor"))
                     .foregroundColor(Color.white)
                     .cornerRadius(100.0)
                   }
                 })
                  
                 .padding(.bottom, 32)
                 .sheet(isPresented: $isShowPhotoLibary){
                     ImagePicker(selectedImage: $viewModel.image)
                 }//Shows another preview layer of the current layer
             
             TextField("Enter with your name:", text: $viewModel.name)
                 .autocapitalization(.none)//Turn off Capslock
                 .disableAutocorrection(false)
                 .padding()
                 .background(Color.white)
                 .cornerRadius(24.0)
                 .overlay(RoundedRectangle(cornerRadius: 24.0)
                             .strokeBorder(Color(UIColor.separator),style: StrokeStyle(lineWidth: 1.0)))
                 .padding(.bottom, 20)
             
             
             TextField("Enter with your email:", text: $viewModel.email)
                 .autocapitalization(.none)//Turn off Capslock
                 .disableAutocorrection(false)
                 .padding()
                 .background(Color.white)
                 .cornerRadius(24.0)
                 .overlay(RoundedRectangle(cornerRadius: 24.0)
                             .strokeBorder(Color(UIColor.separator),style: StrokeStyle(lineWidth: 1.0)))
                 .padding(.bottom, 20)
             
             
             SecureField("Password:", text: $viewModel.password)
                 .autocapitalization(.none)//Turn off Capslock
                 .disableAutocorrection(false)
                 .padding()
                 .background(Color.white)
                 .cornerRadius(24.0)
                 .overlay(RoundedRectangle(cornerRadius: 24.0)
                             .strokeBorder(Color(UIColor.separator),style: StrokeStyle(lineWidth: 1.0)))
                 .padding(.bottom, 30)
             
             if viewModel.isLoading { // Show Loading 
                 ProgressView()
                 .padding()
             }
             
             Button(action: {
                 viewModel.signUp()
             }, label: {
                 Text("Sign In")
                     .frame(maxWidth: .infinity)
                     .padding()
                     .background(Color("GreenColor"))
                     .foregroundColor(Color.white)
                     .cornerRadius(24.0)
             })
             
                 .alert(isPresented: $viewModel.formInvalid) {
                     Alert(title: Text(viewModel.alertText))
                 }
             
         }
         .frame(maxWidth: .infinity, maxHeight: .infinity)
         .padding(.horizontal, 32)
         .background(Color.init(red: 240 / 255, green: 231 / 255, blue: 210 / 255))
     }
 }

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
