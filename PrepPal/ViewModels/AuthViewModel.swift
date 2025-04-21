//
//  AuthViewModel.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/21/25.
//

import Foundation
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var authError: String?

    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        listenToAuthChanges()
    }

    func listenToAuthChanges() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { _, user in
            DispatchQueue.main.async {
                self.user = user
                self.isAuthenticated = (user != nil)
            }
        }
    }

    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let error = error {
                self.authError = error.localizedDescription
            }
        }
    }

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { _, error in
            if let error = error {
                self.authError = error.localizedDescription
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            self.authError = error.localizedDescription
        }
    }

    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
