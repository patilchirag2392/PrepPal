//
//  GroceryListView.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/23/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct GroceryListView: View {
    @EnvironmentObject var recipeVM: RecipeViewModel
    @EnvironmentObject var mealPlannerVM: MealPlannerViewModel

    @State private var groceryItems: [String] = []
    @State private var customItems: [String] = []
    @State private var newItem: String = ""

    private var db = Firestore.firestore()
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HStack {
                    TextField("Add Item", text: $newItem)
                        .padding()
                        .background(Theme.fieldBackground)
                        .cornerRadius(10)

                    Button(action: {
                        if !newItem.isEmpty {
                            customItems.append(newItem)
                            groceryItems.append(newItem)
                            newItem = ""
                            saveGroceryList()
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Theme.primaryColor)
                            .font(.system(size: 28))
                    }
                }
                .padding(.horizontal)

                List {
                    ForEach(groceryItems, id: \.self) { item in
                        Text(item)
                    }
                    .onDelete(perform: deleteItem)
                }
            }
            .background(Theme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Grocery List")
            .navigationBarItems(trailing:
                Button("Generate") {
                    generateGroceryList()
                    saveGroceryList()
                }
            )
        }
        .onAppear {
            recipeVM.loadRecipes()
            mealPlannerVM.loadMealPlan(for: currentWeekId())
            loadGroceryList()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                generateGroceryList()
            }
        }
    }

    func deleteItem(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { groceryItems[$0] }
        groceryItems.remove(atOffsets: offsets)
        customItems.removeAll { itemsToDelete.contains($0) }

        guard let userId = userId else { return }

        db.collection("users").document(userId).getDocument { document, error in
            if var data = document?.data(),
               var savedList = data["groceryList"] as? [String] {
                savedList.removeAll { itemsToDelete.contains($0) }
                db.collection("users").document(userId).setData(["groceryList": savedList], merge: true)
            }

            db.collection("users").document(userId).getDocument { document, error in
                if var data = document?.data(),
                   var groceryItemsData = data["groceryItems"] as? [[String: Any]] {
                    groceryItemsData.removeAll { item in
                        if let name = item["name"] as? String {
                            return itemsToDelete.contains(name)
                        }
                        return false
                    }
                    db.collection("users").document(userId).setData(["groceryItems": groceryItemsData], merge: true)
                }
            }
        }

        for recipe in recipeVM.recipes {
            let ingredientsArray = recipe.ingredients.components(separatedBy: "\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            let filteredIngredients = ingredientsArray.filter { !itemsToDelete.contains($0) }
            let updatedIngredients = filteredIngredients.joined(separator: "\n")

            if updatedIngredients != recipe.ingredients {
                var updatedRecipe = recipe
                updatedRecipe.ingredients = updatedIngredients
                recipeVM.updateRecipe(recipe: updatedRecipe)
            }
        }

        saveGroceryList()
    }
    
    func generateGroceryList() {
        var items: Set<String> = []

        for (_, meals) in mealPlannerVM.mealPlan {
            for (_, recipeTitle) in meals {
                if let recipe = recipeVM.recipes.first(where: { $0.title.lowercased() == recipeTitle.lowercased() }) {
                    let ingredientsArray = recipe.ingredients.components(separatedBy: "\n")
                    items.formUnion(ingredientsArray.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) })
                }
            }
        }

        items.formUnion(customItems)
        groceryItems = Array(items).sorted()
        print("Generated Grocery Items: \(groceryItems)")
    }

    func saveGroceryList() {
        guard let userId = userId else { return }
        db.collection("users").document(userId).setData(["groceryList": groceryItems], merge: true)
    }

    func loadGroceryList() {
        guard let userId = userId else { return }
        db.collection("users").document(userId).getDocument { document, error in
            if let data = document?.data(), let items = data["groceryList"] as? [String] {
                self.groceryItems = items.sorted()
                self.customItems = self.customItems
            }
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
