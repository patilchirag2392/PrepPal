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

    private var db = Firestore.firestore()
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    var body: some View {
        ZStack {
            Theme.backgroundColor.ignoresSafeArea()

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
                                    Button(action: {
                                        toggleFavorite(for: recipe.title)
                                    }) {
                                        Image(systemName: favoriteRecipes.contains(recipe.title) ? "heart.fill" : "heart")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(favoriteRecipes.contains(recipe.title) ? .red : .gray)
                                            .padding(10)
                                            .background(Color.white.opacity(0.001))
                                            .clipShape(Circle())
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedRecipe = recipe
                                }
                                .padding(.vertical, 6)
                            }
                            .onDelete(perform: viewModel.deleteRecipe)
                        }
                        .listStyle(InsetGroupedListStyle())
                        .background(Theme.backgroundColor)
                    }
                }
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
                    loadFavorites()
                }
            }
            .background(Theme.backgroundColor.ignoresSafeArea())
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
