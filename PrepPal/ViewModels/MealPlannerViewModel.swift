//
//  MealPlannerViewModel.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/22/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class MealPlannerViewModel: ObservableObject {
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

    func updateMeal(day: String, mealType: String, recipe: String, weekId: String) {
        mealPlan[day, default: [:]][mealType] = recipe
        saveMealPlan(for: weekId)
    }
}
