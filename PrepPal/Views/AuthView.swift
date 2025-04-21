//
//  AuthView.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/21/25.
//

import SwiftUI

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textInputAutocapitalization(.never)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            Button("Sign In") {
                authVM.signIn(email: email, password: password)
            }

            Button("Sign Up") {
                authVM.signUp(email: email, password: password)
            }

            if let error = authVM.authError {
                Text(error).foregroundColor(.red)
            }
        }
        .padding()
    }
}
