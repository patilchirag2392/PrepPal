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
    @AppStorage("hasLaunched") var hasLaunched = false

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            LauncherView()
                .environmentObject(authVM)
        }
    }
}
