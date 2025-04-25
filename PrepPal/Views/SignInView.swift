//
//  SignInView.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/21/25.
//

import Foundation
import SwiftUI

struct SignInView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var showingSignUp: Bool

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack {
            Color.clear.frame(height:40)

            VStack(spacing: 24) {
                Image("icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .cornerRadius(100)

                Text("Welcome Back!")
                    .font(Theme.titleFont())

                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .padding()
                        .background(Theme.fieldBackground)
                        .cornerRadius(10)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Theme.fieldBackground)
                        .cornerRadius(10)
                }

                Button(action: {
                    authVM.signIn(email: email, password: password)
                }) {
                    Text("Sign In")
                        .font(Theme.buttonFont())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                if let error = authVM.authError {
                    Text(error)
                        .foregroundColor(Theme.errorColor)
                        .font(.caption)
                }

                Button("Don't have an account? Sign Up") {
                    withAnimation {
                        showingSignUp = true
                    }
                }
                .font(.footnote)
                .padding(.top, 8)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .padding()

            Spacer()
        }
        .background(Theme.backgroundColor)
        .ignoresSafeArea()
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.endEditing()
                }
            }
        }
    }
}
