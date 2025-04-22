//
//  AuthView.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/21/25.
//

import SwiftUI

struct AuthView: View {
    @State private var showingSignUp = false

    var body: some View {
        ZStack {
            if showingSignUp {
                SignUpView(showingSignUp: $showingSignUp)
                    .transition(.move(edge: .trailing))
            } else {
                SignInView(showingSignUp: $showingSignUp)
                    .transition(.move(edge: .leading))
            }
        }
        .animation(.easeInOut, value: showingSignUp)
    }
}
