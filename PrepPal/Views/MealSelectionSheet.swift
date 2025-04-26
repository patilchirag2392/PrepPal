//
//  MealSelectionSheet.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/22/25.
//

import SwiftUI

struct MealSelectionSheet: View {
    var sampleRecipes: [String]
    var onSelect: (String) -> Void
    var onRemove: () -> Void
    @Environment(\.presentationMode) var presentationMode

    var showFavoritesToggle: Bool = false
    @Binding var isShowingFavorites: Bool

    var body: some View {
        ZStack {
            Theme.backgroundColor.ignoresSafeArea()

            NavigationView {
                VStack(spacing: 16) {
                    if showFavoritesToggle {
                        Toggle(isOn: $isShowingFavorites) {
                            Text("Favorites Only")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .toggleStyle(SwitchToggleStyle(tint: Theme.primaryColor))
                    }

                    if sampleRecipes.isEmpty {
                        Spacer()
                        Text("No recipes available.\nPlease add a recipe first!")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                            .foregroundColor(.gray)
                        Spacer()
                    } else {
                        List(sampleRecipes, id: \.self) { recipe in
                            Button(action: {
                                onSelect(recipe)
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text(recipe)
                                    .foregroundColor(.primary)
                            }
                        }
                        .listStyle(PlainListStyle())
                    }

                    Button(action: {
                        onRemove()
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Remove Meal")
                        }
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom)
                .navigationTitle("Select a Meal")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
