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
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
