//
//  BudgetView.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/23/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct BudgetView: View {
    @EnvironmentObject var mealPlannerVM: MealPlannerViewModel
    @EnvironmentObject var recipeVM: RecipeViewModel

    @AppStorage("weeklyBudget") var weeklyBudget: Double = 100.0
    @State private var groceryPrices: [String: Double] = [:]
    @State private var groceryItems: [String] = []

    private var db = Firestore.firestore()
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }

    var totalSpent: Double {
        groceryPrices.values.reduce(0, +)
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Text("Budget Tracker")
                        .font(Theme.titleFont())
                        .foregroundColor(.primary)

                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Weekly Budget")
                        .font(Theme.titleFont())
                        .foregroundColor(Theme.primaryColor)

                    HStack {
                        Text("$\(weeklyBudget, specifier: "%.0f")")
                            .font(Theme.subtitleFont())

                        Spacer()

                        Slider(value: $weeklyBudget, in: 0...500, step: 1)
                            .accentColor(Theme.primaryColor)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Spent: $\(totalSpent, specifier: "%.2f") / $\(weeklyBudget, specifier: "%.2f")")
                            .font(.footnote)
                            .foregroundColor(totalSpent > weeklyBudget ? .red : .gray)

                        ProgressView(value: totalSpent, total: weeklyBudget)
                            .accentColor(totalSpent > weeklyBudget ? .red : Theme.primaryColor)
                            .scaleEffect(x: 1, y: 1.5, anchor: .center)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                .padding(.horizontal)

                List {
                    ForEach(groceryItems, id: \.self) { item in
                        HStack {
                            Text(item)
                                .foregroundColor(.primary)

                            Spacer()

                            TextField("Price", value: Binding(
                                get: { groceryPrices[item] ?? 0 },
                                set: { groceryPrices[item] = $0 }
                            ), formatter: NumberFormatter.currency)
                                .keyboardType(.decimalPad)
                                .frame(width: 80)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") {
                            UIApplication.shared.endEditing()
                        }
                    }
                }
            }
            .background(Theme.backgroundColor.ignoresSafeArea())
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .onAppear {
                recipeVM.loadRecipes()
                mealPlannerVM.loadMealPlan(for: currentWeekId())
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    loadGroceryItems()
                    loadBudgetData()
                }
            }
            .onDisappear {
                saveBudgetData()
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

    func loadGroceryItems() {
        var items: Set<String> = []

        for (_, meals) in mealPlannerVM.mealPlan {
            for (_, recipeTitle) in meals {
                if let recipe = recipeVM.recipes.first(where: { $0.title.lowercased() == recipeTitle.lowercased() }) {
                    let ingredientsArray = recipe.ingredients.components(separatedBy: "\n")
                    items.formUnion(ingredientsArray.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) })
                }
            }
        }

        guard let userId = userId else { return }
        db.collection("users").document(userId).getDocument { document, error in
            if let data = document?.data(), let savedItems = data["groceryList"] as? [String] {
                items.formUnion(savedItems.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) })
                DispatchQueue.main.async {
                    groceryItems = Array(items).sorted()
                    self.groceryPrices = self.groceryPrices.filter { self.groceryItems.contains($0.key) }
                }
            } else {
                DispatchQueue.main.async {
                    groceryItems = Array(items).sorted()
                    self.groceryPrices = self.groceryPrices.filter { self.groceryItems.contains($0.key) }
                }
            }
        }
    }

    func saveBudgetData() {
        guard let userId = userId else { return }

        let groceryData = groceryPrices.map { ["name": $0.key, "price": $0.value] }

        db.collection("users").document(userId).setData([
            "weeklyBudget": weeklyBudget,
            "groceryItems": groceryData
        ], merge: true)
    }

    func loadBudgetData() {
        guard let userId = userId else { return }

        db.collection("users").document(userId).getDocument { document, error in
            if let data = document?.data() {
                self.weeklyBudget = data["weeklyBudget"] as? Double ?? 100.0
                if let itemsData = data["groceryItems"] as? [[String: Any]] {
                    for item in itemsData {
                        if let name = item["name"] as? String, let price = item["price"] as? Double {
                            self.groceryPrices[name] = price
                        }
                    }
                }
            }
        }
    }
}

extension NumberFormatter {
    static var currency: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
