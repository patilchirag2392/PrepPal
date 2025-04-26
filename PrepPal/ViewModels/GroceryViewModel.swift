//
//  GroceryViewModel.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/24/25.
//
import Foundation
import FirebaseFirestore
import FirebaseAuth

class GroceryViewModel: ObservableObject {
    @Published var groceryItems: [String] = []
    @Published var customItems: [String] = []
    @Published var isUsingSharedList = false
    @Published var sharedListId: String? = nil

    private var db = Firestore.firestore()
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    func addItem(_ item: String) {
        groceryItems.append(item)
        saveCurrentGroceryList()
    }

    func deleteItem(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { groceryItems[$0] }
        groceryItems.remove(atOffsets: offsets)
        saveCurrentGroceryList()
        customItems.removeAll { itemsToDelete.contains($0) }

        if sharedListId != nil {
            saveSharedGroceryList()
        } else {
            saveGroceryList()
        }
    }

    func generateGroceryList(from mealPlan: [String: [String: String]], recipes: [Recipe]) {
        var items: Set<String> = Set(groceryItems)

        for (_, meals) in mealPlan {
            for (_, recipeTitle) in meals {
                if let recipe = recipes.first(where: { $0.title.lowercased() == recipeTitle.lowercased() }) {
                    let ingredientsArray = recipe.ingredients.components(separatedBy: "\n")
                    items.formUnion(ingredientsArray.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) })
                }
            }
        }

        items.formUnion(customItems)
        groceryItems = Array(items).sorted()
        print("Generated Grocery Items: \(groceryItems)")
    }

    func saveCurrentGroceryList() {
        if sharedListId != nil {
            saveSharedGroceryList()
        } else {
            saveGroceryList()
        }
    }

    func saveUserSharedListId(listId: String) {
        guard let userId = userId else { return }
        db.collection("users").document(userId).setData(["sharedListId": listId], merge: true)
    }

    func saveSharedGroceryList() {
        guard let sharedId = sharedListId else { return }

        db.collection("sharedLists").document(sharedId).setData([
            "items": groceryItems
        ], merge: true)
    }

    func loadSharedGroceryList(listId: String) {
        db.collection("sharedLists").document(listId).addSnapshotListener { snapshot, error in
            if let data = snapshot?.data(), let items = data["items"] as? [String] {
                DispatchQueue.main.async {
                    self.groceryItems = items
                }
            }
        }
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
            }
        }
    }
}


