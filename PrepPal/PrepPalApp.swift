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
    @StateObject var groceryVM = GroceryViewModel()
    @StateObject var mealPlannerVM = MealPlannerViewModel()
    
    @AppStorage("hasLaunched") var hasLaunched = false

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            LauncherView()
                .environmentObject(authVM)
                .environmentObject(groceryVM)
                .environmentObject(mealPlannerVM)
        }
    }
}
