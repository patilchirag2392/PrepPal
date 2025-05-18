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
    
    func deleteRecipe(recipe: Recipe, mealPlannerVM: MealPlannerViewModel, groceryVM: GroceryViewModel) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("users").document(userId).collection("recipes").document(recipe.id).delete { error in
            if let error = error {
                print("❌ Error deleting recipe: \(error.localizedDescription)")
            } else {
                print("✅ Recipe deleted from Firestore.")

                DispatchQueue.main.async {
                    self.recipes.removeAll { $0.id == recipe.id }

                    mealPlannerVM.removeRecipeFromMealPlan(recipeTitle: recipe.title)

                    groceryVM.generateGroceryList(from: mealPlannerVM.mealPlan, recipes: self.recipes)
                    groceryVM.saveCurrentGroceryList()

                    self.loadRecipes()
                    mealPlannerVM.loadMealPlan(for: self.currentWeekId())
                }
            }
        }
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
    
    func saveRecipesToFirestore() {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }

        for recipe in recipes {
            let data: [String: Any] = [
                "title": recipe.title,
                "ingredients": recipe.ingredients,
                "instructions": recipe.instructions
            ]

            db.collection("users").document(userId).collection("recipes").document(recipe.id).setData(data)
        }
    }
    
    func currentWeekId() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let now = Date()
        let weekStart = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        return formatter.string(from: weekStart)
    }
}
