//
//  MealPlannerViewModel.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/22/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseCore
import SwiftUICore

class MealPlannerViewModel: ObservableObject {
    @EnvironmentObject var groceryVM: GroceryViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel
    
    @Published var mealPlan: [String: [String: String]] = [:]
    private var db = Firestore.firestore()

    var userId: String? {
        Auth.auth().currentUser?.uid
    }

    func loadMealPlan(for weekId: String) {
        guard let userId = userId else { return }

        db.collection("users").document(userId)
            .collection("mealPlans").document(weekId)
            .getDocument { document, error in
                if let data = document?.data(), let meals = data["meals"] as? [String: [String: String]] {
                    DispatchQueue.main.async {
                        self.mealPlan = meals
                    }
                }
            }
    }

    func saveMealPlan(for weekId: String) {
        guard let userId = userId else { return }

        db.collection("users").document(userId)
            .collection("mealPlans").document(weekId)
            .setData(["meals": mealPlan]) { error in
                if let error = error {
                    print("Error saving meal plan: \(error.localizedDescription)")
                }
            }
    }
    
    func removeMeal(day: String, mealType: String, weekId: String, groceryVM: GroceryViewModel, recipeVM: RecipeViewModel) {
        guard var mealsForDay = mealPlan[day] else { return }

        mealsForDay[mealType] = nil
        mealPlan[day] = mealsForDay

        guard let userId = Auth.auth().currentUser?.uid else { return }
        let mealRef = db.collection("users").document(userId).collection("mealPlans").document(weekId)

        mealRef.updateData([
            "meals.\(day).\(mealType)": FieldValue.delete()
        ]) { error in
            if let error = error {
                print("❌ Firestore field delete error: \(error.localizedDescription)")
            } else {
                print("✅ Firestore field deleted for \(day) - \(mealType)")
            }

            mealRef.updateData([
                "meals": self.mealPlan
            ]) { saveError in
                if let saveError = saveError {
                    print("❌ Error saving remaining meal plan: \(saveError.localizedDescription)")
                } else {
                    print("✅ Meal plan saved after deletion: \(self.mealPlan)")
                }
            }
        }

        groceryVM.generateGroceryList(from: mealPlan, recipes: recipeVM.recipes)
        groceryVM.saveCurrentGroceryList()
    }
    
    func removeRecipeFromMealPlan(recipeTitle: String) {
        var updated = false

        for (day, meals) in mealPlan {
            var dayMeals = meals
            for (mealType, title) in meals {
                if title == recipeTitle {
                    dayMeals[mealType] = nil
                    updated = true
                }
            }
            mealPlan[day] = dayMeals
        }

        if updated {
            saveMealPlan(for: currentWeekId())
        }
    }

    func currentWeekId() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let now = Date()
        let weekStart = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        return formatter.string(from: weekStart)
    }

    func updateMeal(day: String, mealType: String, recipe: String, weekId: String) {
        mealPlan[day, default: [:]][mealType] = recipe
        saveMealPlan(for: weekId)
    }
}


