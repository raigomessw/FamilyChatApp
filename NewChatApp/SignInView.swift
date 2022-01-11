//
//  ContentView.swift
//  NewChatApp
//
//  Created by Rai Gomes on 2022-01-11.
//

import SwiftUI

struct SignInView: View {
    
   @StateObject var viewModel = SignInViewModel()//State of Obeject help to see the object into the class. All info av logic code stay into class SignViewModel
    
    var body: some View {
        
        NavigationView{
            
        
        VStack{
            Image("logo")
            .resizable()
            .frame(width: 150.0, height: 150.0)
            .scaledToFit()
            .padding()
            Text("Family Chat App")
            .padding()
            
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
                viewModel.signIn()
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
            
            
            NavigationLink(destination: SignUpView()) { //To work navigation link need be enveloped in the other componentView = NagigationView
                Text("I have no account!")
                    .foregroundColor(Color.black)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
        .background(Color.init(red: 240 / 255, green: 231 / 255, blue: 210 / 255))
        .navigationTitle("Login")
        .navigationBarHidden(true)
     }
   }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
