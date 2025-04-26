//
//  MealPlannerView.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/22/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct MealPlannerView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var groceryVM: GroceryViewModel
    @EnvironmentObject var viewModel: MealPlannerViewModel
    @AppStorage("weeklyBudget") var weeklyBudget: Double = 100.0
    @State private var mealPreference: String = "No Preference"
    @State private var favoriteRecipes: [String] = []
    @State private var showOnlyFavorites = false
    @State private var isShowingFavorites: Bool = false
    @StateObject private var recipeVM = RecipeViewModel()
    @State private var isLoadingAI = false
    @State private var aiErrorMessage: String? = nil
    
    let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let mealTypes = [("Breakfast", "sunrise.fill"), ("Lunch", "fork.knife"), ("Dinner", "moon.stars.fill")]
    
    @State private var selectedDay = ""
    @State private var selectedMealType = ""
    @State private var showingMealSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                headerView
                mealPlanScrollView
            }
            .background(Theme.backgroundColor.ignoresSafeArea())
            .sheet(isPresented: $showingMealSheet) {
                MealSelectionSheet(
                    sampleRecipes: isShowingFavorites ?
                        recipeVM.recipes.filter { favoriteRecipes.contains($0.title) }.map { $0.title } :
                        recipeVM.recipes.map { $0.title },
                    onSelect: { recipe in
                        viewModel.updateMeal(day: selectedDay, mealType: selectedMealType, recipe: recipe, weekId: currentWeekId())
                        showingMealSheet = false
                    },
                    onRemove: {
                        viewModel.removeMeal(
                            day: selectedDay,
                            mealType: selectedMealType,
                            weekId: currentWeekId(),
                            groceryVM: groceryVM,
                            recipeVM: recipeVM
                        )
                        showingMealSheet = false
                    },
                    showFavoritesToggle: true,
                    isShowingFavorites: $isShowingFavorites
                )
            }
            .onAppear {
                loadMealPreference()
                viewModel.loadMealPlan(for: currentWeekId())
                recipeVM.loadRecipes()
                loadFavorites()
                
                print("🔄 Reloaded Meal Plan on Appear: \(viewModel.mealPlan)")
            }
        }
    }

    private var headerView: some View {
        HStack {
            Text("Meal Planner")
                .font(Theme.titleFont())
                .foregroundColor(.primary)

            Spacer()

            Button(action: {
                print("✨ Suggest Meals button tapped")
                fetchLocalMealSuggestions(budget: weeklyBudget, preference: mealPreference)
            }) {
                Image(systemName: "sparkles")
                    .font(.system(size: 22))
                    .foregroundColor(Theme.primaryColor)
            }
        }
        .padding(.horizontal)
        .padding(.top)
    }

    private var mealPlanScrollView: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(daysOfWeek, id: \.self) { day in
                    dayMealCard(for: day)
                }
            }
            .padding(.top)
        }
    }

    private func dayMealCard(for day: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(day)
                .font(Theme.subtitleFont())
                .foregroundColor(.gray)
                .padding(.leading)

            ForEach(mealTypes, id: \.0) { meal, icon in
                mealRow(for: day, meal: meal, icon: icon)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color.white.opacity(0.9))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }

    private func mealRow(for day: String, meal: String, icon: String) -> some View {
        HStack {
            Label(meal, systemImage: icon)
                .font(.headline)
                .foregroundColor(.primary)

            Spacer()

            Text(viewModel.mealPlan[day]?[meal] ?? "Add Meal")
                .foregroundColor(.blue)
                .onTapGesture {
                    selectedDay = day
                    selectedMealType = meal
                    showingMealSheet = true
                }
        }
        .padding()
        .background(Theme.fieldBackground)
        .cornerRadius(12)
    }

    func currentWeekId() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let now = Date()
        let weekStart = Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        return formatter.string(from: weekStart)
    }
    
    func extractJSON(from text: String) -> String? {
        guard let startIndex = text.firstIndex(of: "{"),
              let endIndex = text.lastIndex(of: "}") else {
            return nil
        }
        
        let jsonRange = startIndex...endIndex
        let jsonString = String(text[jsonRange])
        return jsonString
    }
    
    func loadFavorites() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).collection("favorites").getDocuments { snapshot, error in
            if let docs = snapshot?.documents {
                self.favoriteRecipes = docs.compactMap { $0.data()["title"] as? String }
                print("❤️ Loaded favorites: \(self.favoriteRecipes)")
            }
        }
    }
    
    func loadMealPreference() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let data = document?.data() {
                self.mealPreference = data["mealPreference"] as? String ?? "No Preference"
                print("🍽️ Loaded meal preference: \(self.mealPreference)")
            }
        }
    }
    
    func fetchLocalMealSuggestions(budget: Double, preference: String) {
        isLoadingAI = true
        aiErrorMessage = nil

        let prompt = """
        Suggest a weekly meal plan for 7 days in the following JSON format. For each meal (Breakfast, Lunch, Dinner), include a meal name and up to 3 ingredients required for that meal. The total cost of ingredients for all meals should not exceed $\(budget) and it should align with the user's \(preference). also the ingredients should be just the name of the ingredient, no need to give the quantity of that particular ingredient

        Return the answer data in a JSON format, with name of the dish in Meal Name, and it's ingredients in Ingredient 1, 2 and 3. use the format given below for the response:

        {
          "mealPlan": {
            "Mon": {
              "Breakfast": {
                "meal": "Meal Name",
                "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
              },
              "Lunch": {
                "meal": "Meal Name",
                "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
              },
              "Dinner": {
                "meal": "Meal Name",
                "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
              }
            },
            "Tue": {
              "Breakfast": {
                "meal": "Meal Name",
                "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
              },
              "Lunch": {
                "meal": "Meal Name",
                "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
              },
              "Dinner": {
                "meal": "Meal Name",
                "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
              }
            },
            "Wed": {
              "Breakfast": {
                "meal": "Meal Name",
                "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
              },
              "Lunch": {
                "meal": "Meal Name",
                "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
              },
              "Dinner": {
                "meal": "Meal Name",
                "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
              }
            },
            "Thu": {
              "Breakfast": {
                "meal": "Meal Name",
                "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
              },
              "Lunch": {
                "meal": "Meal Name",
                "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
              },
              "Dinner": {
                "meal": "Meal Name",
                "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
              }
            },
            "Fri": {
              "Breakfast": {
                "meal": "Meal Name",
                "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
              },
              "Lunch": {
                "meal": "Meal Name",
                "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
              },
              "Dinner": {
                "meal": "Meal Name",
                "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
              }
            },
            "Sat": {
              "Breakfast": {
                "meal": "Meal Name",
                "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
              },
              "Lunch": {
                "meal": "Meal Name",
                "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
              },
              "Dinner": {
                "meal": "Meal Name",
                "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
              }
            },
            "Sun": {
              "Breakfast": {
                "meal": "Meal Name",
                "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
              },
              "Lunch": {
                "meal": "Meal Name",
                "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
              },
              "Dinner": {
                "meal": "Meal Name",
                "ingredients": ["Ingredient 1", "Ingredient 2", "Ingredient 3"]
              }
            }
          }
        }

        instructions for output:
        - Return ONLY valid JSON as shown above.
        - Make sure all the days and the meal times, i.e. breakfast, lunch and dinner is filled.
        - Give actual meals and ingredients, no placeholder data
        - Make sure you work and give the similar outout even after re-running the prompt
        - No extra text, explanations, or formatting outside the JSON block.
        """


        LocalLLMService.shared.getMealSuggestions(prompt: prompt) { result in
                isLoadingAI = false
                switch result {
                case .success(let suggestionText):
                    print("✅ Raw AI Response: \(suggestionText)")

                    if let cleanJSON = extractJSON(from: suggestionText),
                       let planData = cleanJSON.data(using: .utf8) {
                        do {
                            if let result = try JSONSerialization.jsonObject(with: planData, options: []) as? [String: Any],
                               let mealPlanRaw = result["mealPlan"] as? [String: [String: [String: Any]]] {

                                var newMealPlan: [String: [String: String]] = [:]
                                var allIngredients: Set<String> = []

                                for (day, meals) in mealPlanRaw {
                                    var dayMeals: [String: String] = [:]
                                    for (time, details) in meals {
                                        if let mealName = details["meal"] as? String,
                                           let ingredients = details["ingredients"] as? [String] {
                                            dayMeals[time] = mealName
                                            allIngredients.formUnion(ingredients)
                                        }
                                    }
                                    newMealPlan[day] = dayMeals
                                }

                                DispatchQueue.main.async {
                                    viewModel.mealPlan = newMealPlan
                                    viewModel.saveMealPlan(for: currentWeekId())

                                    groceryVM.groceryItems.append(contentsOf: allIngredients.filter { !groceryVM.groceryItems.contains($0) })
                                    groceryVM.saveCurrentGroceryList()

                                    print("🗂 Updated Meal Plan: \(viewModel.mealPlan)")
                                    print("🛒 Updated Grocery List: \(groceryVM.groceryItems)")
                                }

                            } else {
                                print("⚠️ No 'mealPlan' found in JSON.")
                                aiErrorMessage = "No mealPlan found in AI response."
                            }
                        } catch {
                            print("❌ JSON Parsing Error: \(error.localizedDescription)")
                            aiErrorMessage = "Failed to parse AI response: \(error.localizedDescription)"
                        }
                    } else {
                        print("❌ Failed to extract JSON block from AI response.")
                        aiErrorMessage = "Could not find valid JSON in AI response."
                    }

                case .failure(let error):
                    aiErrorMessage = "Local Suggestion Failed: \(error.localizedDescription)"
                    print("❌ Local LLM Error: \(error.localizedDescription)")
                }
            }
    }
}

struct DayMealSection: View {
    let day: String
    let mealTypes: [(String, String)]
    let meals: [String: String]
    let onMealTap: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(day)
                .font(Theme.subtitleFont())
                .foregroundColor(.gray)
                .padding(.leading)

            VStack(spacing: 12) {
                ForEach(mealTypes, id: \.0) { meal, icon in
                    HStack {
                        Label(meal, systemImage: icon)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Spacer()

                        Text(meals[meal] ?? "Add Meal")
                            .foregroundColor(.blue)
                            .onTapGesture {
                                onMealTap(meal)
                            }
                    }
                    .padding()
                    .background(Theme.fieldBackground)
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color.white.opacity(0.9))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}
