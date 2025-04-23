//
//  RecipesView.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/22/25.
//

import SwiftUI

struct RecipesView: View {
    @StateObject private var viewModel = RecipeViewModel()
    @State private var showingAddRecipe = false

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.recipes) { recipe in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recipe.title)
                            .font(.headline)
                        Text(recipe.ingredients)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete(perform: viewModel.deleteRecipe)
            }
            .navigationTitle("My Recipes")
            .navigationBarItems(trailing:
                Button(action: {
                    showingAddRecipe = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(Theme.primaryColor)
                }
            )
            .sheet(isPresented: $showingAddRecipe) {
                AddRecipeView { newRecipe in
                    viewModel.addRecipe(recipe: newRecipe)
                    showingAddRecipe = false
                }
            }
            .onAppear {
                viewModel.loadRecipes()
            }
        }
    }
}
