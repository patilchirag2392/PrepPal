//
//  EditRecipeView.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/23/25.
//

import SwiftUI

struct EditRecipeView: View {
    @State var recipe: Recipe
    var onSave: (Recipe) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Recipe Title", text: $recipe.title)
                }
                Section(header: Text("Ingredients")) {
                    TextEditor(text: $recipe.ingredients)
                        .frame(height: 100)
                }
                Section(header: Text("Instructions")) {
                    TextEditor(text: $recipe.instructions)
                        .frame(height: 150)
                }
            }
            .navigationTitle("Edit Recipe")
            .navigationBarItems(trailing:
                Button("Save") {
                    onSave(recipe)
                }
            )
        }
    }
}
