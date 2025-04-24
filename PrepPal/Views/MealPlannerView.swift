//
//  MealPlannerView.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/22/25.
//

import SwiftUI

struct MealPlannerView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var viewModel = MealPlannerViewModel()
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
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(daysOfWeek, id: \.self) { day in
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
                .padding(.top)
            }
            .background(Theme.backgroundColor)
            .navigationTitle("Meal Planner")
            .navigationBarItems(
                leading:
                    Button(action: {
                        print("✨ Suggest Meals button tapped")
                        fetchLocalMealSuggestions()
                    }) {
                        Label("Suggest Meals", systemImage: "sparkles")
                            .foregroundColor(Theme.primaryColor)
                    },
                trailing:
                    Button(action: {
                        authVM.signOut()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.forward")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundColor(Theme.primaryColor)
                    }
            )
            .sheet(isPresented: $showingMealSheet) {
                MealSelectionSheet(
                    sampleRecipes: recipeVM.recipes.map { $0.title },
                    onSelect: { recipe in
                        viewModel.updateMeal(day: selectedDay, mealType: selectedMealType, recipe: recipe, weekId: currentWeekId())
                        showingMealSheet = false
                    }
                )
            }
            .onAppear {
                viewModel.loadMealPlan(for: currentWeekId())
                recipeVM.loadRecipes()
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
    
    func fetchLocalMealSuggestions() {
        isLoadingAI = true
        aiErrorMessage = nil

        let prompt = """
        Suggest a weekly meal plan in the following JSON format, with Breakfast, Lunch, and Dinner for each day:

        {
          "Mon": {"Breakfast": "Meal", "Lunch": "Meal", "Dinner": "Meal"},
          "Tue": {"Breakfast": "Meal", "Lunch": "Meal", "Dinner": "Meal"},
          "Wed": {"Breakfast": "Meal", "Lunch": "Meal", "Dinner": "Meal"},
          "Thu": {"Breakfast": "Meal", "Lunch": "Meal", "Dinner": "Meal"},
          "Fri": {"Breakfast": "Meal", "Lunch": "Meal", "Dinner": "Meal"},
          "Sat": {"Breakfast": "Meal", "Lunch": "Meal", "Dinner": "Meal"},
          "Sun": {"Breakfast": "Meal", "Lunch": "Meal", "Dinner": "Meal"}
        }

        Please return ONLY valid JSON exactly like the above format, with no additional text.
        """

        LocalLLMService.shared.getMealSuggestions(prompt: prompt) { result in
            isLoadingAI = false
            switch result {
            case .success(let suggestionText):
                print("✅ Raw AI Response: \(suggestionText)")

                if let planData = suggestionText.data(using: .utf8),
                   let plan = try? JSONSerialization.jsonObject(with: planData) as? [String: [String: String]] {
                    print("🗂 Parsed JSON Meal Plan: \(plan)")
                    DispatchQueue.main.async {
                        viewModel.mealPlan = plan
                        viewModel.saveMealPlan(for: currentWeekId())
                    }
                } else {
                    print("⚠️ Failed to parse JSON from AI response.")
                    aiErrorMessage = "Failed to parse AI response."
                }

            case .failure(let error):
                aiErrorMessage = "Local Suggestion Failed: \(error.localizedDescription)"
                print("❌ Local LLM Error: \(error.localizedDescription)")
            }
        }
    }
    
//    func fetchMealSuggestionsWithGemini() {
//        isLoadingAI = true
//        aiErrorMessage = nil
//
//        let prompt = "Suggest a weekly meal plan with Breakfast, Lunch, and Dinner for 7 days."
//
//        GeminiService.shared.getMealSuggestions(prompt: prompt) { result in
//            isLoadingAI = false
//            switch result {
//            case .success(let suggestionText):
//                print("✅ Gemini Suggested Meals: \(suggestionText)")
//                // Parse and fill into mealPlan if needed
//            case .failure(let error):
//                aiErrorMessage = "Gemini Suggestion Failed: \(error.localizedDescription)"
//                print("❌ Gemini Error: \(error.localizedDescription)")
//            }
//        }
//    }
}

//    func suggestMeals() {
//        guard !recipeVM.recipes.isEmpty else { return }
//
//        var newMealPlan: [String: [String: String]] = [:]
//
//        for day in daysOfWeek {
//            var mealsForDay: [String: String] = [:]
//            for (mealType, _) in mealTypes {
//                let randomRecipe = recipeVM.recipes.randomElement()
//                mealsForDay[mealType] = randomRecipe?.title ?? "TBD"
//            }
//            newMealPlan[day] = mealsForDay
//        }
//
//        viewModel.mealPlan = newMealPlan
//        viewModel.saveMealPlan(for: currentWeekId())
//    }

