//
//  MainTabView.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/23/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var mealPlannerVM = MealPlannerViewModel()
    @StateObject var recipeVM = RecipeViewModel()

    var body: some View {
        TabView {
            MealPlannerView()
                .environmentObject(mealPlannerVM)
                .environmentObject(recipeVM)
                .tabItem {
                    Label("Planner", systemImage: "calendar")
                }

            RecipesView()
                .environmentObject(mealPlannerVM)
                .environmentObject(recipeVM)
                .tabItem {
                    Label("My Recipes", systemImage: "book")
                }

            GroceryListView()
                .environmentObject(mealPlannerVM)
                .environmentObject(recipeVM)
                .tabItem {
                    Label("Grocery", systemImage: "cart")
                }

            BudgetView()
                .environmentObject(mealPlannerVM)
                .environmentObject(recipeVM)
                .tabItem {
                    Label("Budget", systemImage: "dollarsign.circle")
                }

            ProfileView()
                .environmentObject(mealPlannerVM)
                .environmentObject(recipeVM)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}
