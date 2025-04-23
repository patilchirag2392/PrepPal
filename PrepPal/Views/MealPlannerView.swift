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
            .navigationBarItems(trailing:
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
}
