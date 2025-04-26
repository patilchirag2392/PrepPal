//
//  RecipesView.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/22/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RecipesView: View {
    @StateObject private var viewModel = RecipeViewModel()
    @State private var showingAddRecipe = false
    @State private var selectedRecipe: Recipe? = nil
    @State private var favoriteRecipes: Set<String> = []
    @EnvironmentObject var groceryVM: GroceryViewModel
    @EnvironmentObject var mealPlannerVM: MealPlannerViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel

    private var db = Firestore.firestore()
    private var userId: String? { Auth.auth().currentUser?.uid }

    var body: some View {
        ZStack {
            Theme.backgroundColor.ignoresSafeArea()

            VStack {
                HStack {
                    Text("My Recipes")
                        .font(Theme.titleFont())
                        .foregroundColor(.primary)

                    Spacer()

                    Button(action: {
                        showingAddRecipe = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(Theme.primaryColor)
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                if viewModel.recipes.isEmpty {
                    EmptyRecipesView()
                } else {
                    RecipesListView()
                }
            }
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
                loadFavorites()
            }
        }
    }

    @ViewBuilder
    private func EmptyRecipesView() -> some View {
        VStack {
            Spacer()
            Text("No recipes yet!")
                .font(Theme.titleFont())
                .foregroundColor(.gray)
            Spacer()
        }
    }

    @ViewBuilder
    private func RecipesListView() -> some View {
        List {
            ForEach(viewModel.recipes) { recipe in
                RecipeRow(recipe: recipe)
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    let recipe = viewModel.recipes[index]
                    viewModel.deleteRecipe(recipe: recipe, mealPlannerVM: mealPlannerVM, groceryVM: groceryVM)
                }
            }
        }
        .listStyle(PlainListStyle())
        .background(Theme.backgroundColor)
        .scrollContentBackground(.hidden) 
    }

    @ViewBuilder
    private func RecipeRow(recipe: Recipe) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(recipe.ingredients)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            FavoriteButton(for: recipe)
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedRecipe = recipe
        }
    }

    @ViewBuilder
    private func FavoriteButton(for recipe: Recipe) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                toggleFavorite(for: recipe.title)
            }
        }) {
            Image(systemName: favoriteRecipes.contains(recipe.title) ? "heart.fill" : "heart")
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundColor(favoriteRecipes.contains(recipe.title) ? .red : .gray)
                .scaleEffect(favoriteRecipes.contains(recipe.title) ? 1.2 : 1.0)
        }
    }

    private var addButton: some View {
        Button(action: {
            showingAddRecipe = true
        }) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(Theme.primaryColor)
        }
    }

    func toggleFavorite(for title: String) {
        guard let userId = userId else { return }
        let userFavoritesRef = db.collection("users").document(userId).collection("favorites")

        if favoriteRecipes.contains(title) {
            userFavoritesRef.document(title).delete { error in
                if error == nil {
                    favoriteRecipes.remove(title)
                }
            }
        } else {
            userFavoritesRef.document(title).setData(["title": title]) { error in
                if error == nil {
                    favoriteRecipes.insert(title)
                }
            }
        }
    }

    func loadFavorites() {
        guard let userId = userId else { return }
        db.collection("users").document(userId).collection("favorites").getDocuments { snapshot, error in
            if let docs = snapshot?.documents {
                let titles = docs.compactMap { $0.data()["title"] as? String }
                favoriteRecipes = Set(titles)
            }
        }
    }
}
