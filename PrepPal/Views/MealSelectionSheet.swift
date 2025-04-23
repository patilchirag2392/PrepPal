//
//  MealSelectionSheet.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/22/25.
//

import SwiftUI

struct MealSelectionSheet: View {
    let sampleRecipes: [String]
    var onSelect: (String) -> Void

    var body: some View {
        NavigationView {
            List(sampleRecipes, id: \.self) { recipe in
                Text(recipe)
                    .onTapGesture {
                        onSelect(recipe)
                    }
            }
            .navigationTitle("Select a Meal")
        }
    }
}
