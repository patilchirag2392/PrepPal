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
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Theme.backgroundColor.ignoresSafeArea() // 💥 Fully fill background

            NavigationView {
                VStack {
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
                }
                .navigationTitle("Select a Meal")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
