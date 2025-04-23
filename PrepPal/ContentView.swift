//
//  ContentView.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/21/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject var mealPlannerVM = MealPlannerViewModel()
    @StateObject var recipeVM = RecipeViewModel()
    
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
}
