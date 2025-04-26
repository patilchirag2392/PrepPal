//
//  PrepPalApp.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/21/25.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct PrepPalApp: App {
    @StateObject var authVM = AuthViewModel()
    @StateObject var groceryVM = GroceryViewModel()
    @StateObject var mealPlannerVM = MealPlannerViewModel()
    @StateObject var recipeVM = RecipeViewModel()
    
    @AppStorage("hasLaunched") var hasLaunched = false

    init() {
        FirebaseApp.configure()
        
        let cacheSettings = PersistentCacheSettings()

        let settings = FirestoreSettings()
        settings.cacheSettings = cacheSettings

        let db = Firestore.firestore()
        db.settings = settings

        print("✅ Firestore Offline Persistence Enabled with PersistentCacheSettings")
    }

    var body: some Scene {
        WindowGroup {
            LauncherView()
                .environmentObject(authVM)
                .environmentObject(groceryVM)
                .environmentObject(mealPlannerVM)
                .environmentObject(recipeVM)
        }
    }
}
