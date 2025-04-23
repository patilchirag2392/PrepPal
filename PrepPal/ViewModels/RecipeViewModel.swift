//
//  RecipeViewModel.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/22/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class RecipeViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    private var db = Firestore.firestore()

    var userId: String? {
        Auth.auth().currentUser?.uid
    }

    func loadRecipes() {
        guard let userId = userId else { return }

        db.collection("users").document(userId).collection("recipes")
            .getDocuments { snapshot, error in
                if let snapshot = snapshot {
                    self.recipes = snapshot.documents.compactMap { doc in
                        try? doc.data(as: Recipe.self)
                    }
                    print("Recipes loaded: \(self.recipes.map { $0.title })")
                }
            }
    }

    func addRecipe(recipe: Recipe) {
        guard let userId = userId else { return }

        do {
            try db.collection("users").document(userId).collection("recipes").document(recipe.id).setData(from: recipe)
            recipes.append(recipe)
        } catch {
            print("Error adding recipe: \(error.localizedDescription)")
        }
    }

    func deleteRecipe(at offsets: IndexSet) {
        guard let userId = userId else { return }

        offsets.forEach { index in
            let recipe = recipes[index]
            db.collection("users").document(userId).collection("recipes").document(recipe.id).delete()
        }
        recipes.remove(atOffsets: offsets)
    }
    
    func updateRecipe(recipe: Recipe) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        do {
            try db.collection("users").document(userId).collection("recipes").document(recipe.id).setData(from: recipe)
            if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
                recipes[index] = recipe
            }
        } catch {
            print("Error updating recipe: \(error.localizedDescription)")
        }
    }
}
