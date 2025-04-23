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
    @State private var selectedRecipe: Recipe? = nil

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.recipes.isEmpty {
                    Spacer()
                    Text("No recipes yet!")
                        .font(Theme.titleFont())
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.recipes) { recipe in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(recipe.title)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(recipe.ingredients)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 6)
                            .onTapGesture {
                                selectedRecipe = recipe
                            }
                        }
                        .onDelete(perform: viewModel.deleteRecipe)
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .background(Theme.backgroundColor.ignoresSafeArea())
            .navigationTitle("My Recipes")
            .navigationBarItems(trailing:
                Button(action: {
                    showingAddRecipe = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(Theme.primaryColor)
                }
            )
            .sheet(item: $selectedRecipe) { recipe in
                EditRecipeView(recipe: recipe) { updatedRecipe in
                    viewModel.updateRecipe(recipe: updatedRecipe)
                    selectedRecipe = nil
                }
            }
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
