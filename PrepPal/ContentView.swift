//
//  ContentView.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/21/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
//        MealPlannerView()
        RecipesView()
    }
}

#Preview {
    ContentView()
}
