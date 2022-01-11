//
//  SignUpView.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-11.
//

import SwiftUI

struct SignUpView: View {
    @StateObject var viewModel = SignUpViewModel()//State of Obeject help to see the object into the class. All info av logic code stay into class SignViewModel
     
     var body: some View {
         
     
         VStack{
             Image("logo")
             .resizable()
             .frame(width: 150.0, height: 150.0)
             .scaledToFit()
             .padding()
             Text("Family Chat App")
             .padding()
             
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
             Divider()
                 .padding()
             
             Button(action: {
                 print("Clikado 2")
             }, label: {
                 Text("I have no account!")
                     .foregroundColor(Color.black)
             })
             
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
