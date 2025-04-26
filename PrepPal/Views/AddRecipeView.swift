//
//  AddRecipeView.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/22/25.
//

import SwiftUI

struct AddRecipeView: View {
    @State private var title = ""
    @State private var ingredients = ""
    @State private var instructions = ""
    var onSave: (Recipe) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Recipe Title", text: $title)
                }
                Section(header: Text("Ingredients")) {
                    TextEditor(text: $ingredients)
                        .frame(height: 100)
                }
                Section(header: Text("Instructions")) {
                    TextEditor(text: $instructions)
                        .frame(height: 150)
                }
            }
            .navigationTitle("Add Recipe")
            .navigationBarItems(trailing:
                Button("Save") {
                    let recipe = Recipe(id: UUID().uuidString, title: title, ingredients: ingredients, instructions: instructions)
                    onSave(recipe)
                }
                .disabled(title.isEmpty || ingredients.isEmpty)
            )
        }
    }
}


