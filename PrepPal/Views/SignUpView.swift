//
//  SignUpView.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/21/25.
//

import Foundation
import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Binding var showingSignUp: Bool
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    @State private var passwordError = ""

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var localError = ""

    var body: some View {
        VStack {
            Color.clear.frame(height:40)

            VStack(spacing: 24) {
                Image("icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .cornerRadius(100)

                Text("Create Account")
                    .font(Theme.titleFont())

                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .padding()
                        .background(Theme.fieldBackground)
                        .cornerRadius(10)

                    ZStack(alignment: .trailing) {
                        Group {
                            if isPasswordVisible {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
                            }
                        }
                        .padding()
                        .background(Theme.fieldBackground)
                        .cornerRadius(10)

                        Button(action: { isPasswordVisible.toggle() }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }

                    ZStack(alignment: .trailing) {
                        Group {
                            if isConfirmPasswordVisible {
                                TextField("Confirm Password", text: $confirmPassword)
                            } else {
                                SecureField("Confirm Password", text: $confirmPassword)
                            }
                        }
                        .padding()
                        .background(Theme.fieldBackground)
                        .cornerRadius(10)

                        Button(action: { isConfirmPasswordVisible.toggle() }) {
                            Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                                .padding()
                        }
                    }
                }

                if !passwordError.isEmpty {
                    Text(passwordError)
                        .foregroundColor(Theme.errorColor)
                        .font(.caption)
                }

                Button("Sign Up") {
                    passwordError = validatePassword(password)
                    guard passwordError.isEmpty else { return }

                    if password != confirmPassword {
                        localError = "Passwords do not match."
                        return
                    }
                    authVM.signUp(email: email, password: password)
                }
                .font(Theme.buttonFont())
                .frame(maxWidth: .infinity)
                .padding()
                .background(Theme.primaryColor)
                .foregroundColor(.white)
                .cornerRadius(10)
                .buttonStyle(ScaleButtonStyle())

                if let error = authVM.authError ?? (localError.isEmpty ? nil : localError) {
                    Text(error)
                        .foregroundColor(Theme.errorColor)
                        .font(.caption)
                }

                Button("Already have an account? Sign In") {
                    withAnimation {
                        showingSignUp = false
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
    
    func validatePassword(_ password: String) -> String {
        if password.count < 6 {
            return "Password must be at least 6 characters."
        }
        if !password.contains(where: { $0.isUppercase }) {
            return "Password must contain at least 1 uppercase letter."
        }
        if !password.contains(where: { $0.isLowercase }) {
            return "Password must contain at least 1 lowercase letter."
        }
        if !password.contains(where: { $0.isNumber }) {
            return "Password must contain at least 1 number."
        }
        return ""
    }
}
