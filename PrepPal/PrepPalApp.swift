//
//  PrepPalApp.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/21/25.
//

import SwiftUI
import Firebase

@main
struct PrepPalApp: App {
    @StateObject var authVM = AuthViewModel()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if authVM.isAuthenticated {
                ContentView()
                    .environmentObject(authVM)
            } else {
                AuthView()
                    .environmentObject(authVM)
            }
        }
    }
}
