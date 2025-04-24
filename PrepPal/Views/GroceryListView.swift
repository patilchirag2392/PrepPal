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
    @EnvironmentObject var groceryVM: GroceryViewModel

    @State private var showingSharedListOptions = false
    @State private var newItem: String = ""

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
                            groceryVM.addItem(newItem)
                            newItem = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Theme.primaryColor)
                            .font(.system(size: 28))
                    }
                }
                .padding(.horizontal)

                Toggle(isOn: $groceryVM.isUsingSharedList) {
                    Text("Use Shared Grocery List")
                        .font(.headline)
                        .foregroundColor(Theme.primaryColor)
                }
                .padding(.horizontal)
                .onChange(of: groceryVM.isUsingSharedList) { newValue in
                    if newValue {
                        showingSharedListOptions = true
                    } else {
                        groceryVM.sharedListId = nil
                        groceryVM.loadGroceryList()
                    }
                }
                .sheet(isPresented: $showingSharedListOptions) {
                    SharedListOptionsView(sharedListId: $groceryVM.sharedListId, isUsingSharedList: $groceryVM.isUsingSharedList) { listId in
                        groceryVM.sharedListId = listId
                        groceryVM.saveUserSharedListId(listId: listId)
                        groceryVM.loadSharedGroceryList(listId: listId)
                    }
                }

                List {
                    ForEach(groceryVM.groceryItems, id: \.self) { item in
                        Text(item)
                    }
                    .onDelete { offsets in
                        groceryVM.deleteItem(at: offsets, recipeVM: recipeVM)
                    }
                }
            }
            .background(Theme.backgroundColor.ignoresSafeArea())
            .navigationTitle("Grocery List")
            .navigationBarItems(trailing:
                Button("Generate") {
                    groceryVM.generateGroceryList(from: mealPlannerVM.mealPlan, recipes: recipeVM.recipes)
                    groceryVM.saveCurrentGroceryList()
                }
            )
        }
        .onAppear {
            recipeVM.loadRecipes()
            mealPlannerVM.loadMealPlan(for: currentWeekId())
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                groceryVM.generateGroceryList(from: mealPlannerVM.mealPlan, recipes: recipeVM.recipes)
                groceryVM.loadGroceryList()
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
