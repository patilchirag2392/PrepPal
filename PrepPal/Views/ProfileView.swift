//
//  ProfileView.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/24/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var name: String = ""
    @State private var university: String = ""
    @State private var major: String = ""
    @State private var isEditing = false
    @State private var mealPreference: String = "No Preference"

    let mealOptions = ["No Preference", "Vegetarian", "Vegan", "Non-Vegetarian", "Budget-Friendly", "High-Protein"]

    @State private var savedRecipesCount: Int = 0
    @State private var mealsPlannedCount: Int = 0

    var body: some View {
        ZStack {
            Theme.backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    HStack {
                        Text("Profile")
                            .font(Theme.titleFont())
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding(.horizontal)
                    Spacer(minLength: 10)

                    Text("👋🏻 Welcome, \(name.isEmpty ? "Student" : name)!")
                        .font(Theme.titleFont())
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 15) {
                        profileField(label: "Name", value: $name)
                        profileField(label: "University", value: $university)
                        profileField(label: "Course", value: $major)
                        VStack(alignment: .leading) {
                            Text("Meal Preference:").bold()
                            if isEditing {
                                Picker("Meal Preference", selection: $mealPreference) {
                                    ForEach(mealOptions, id: \.self) { option in
                                        Text(option)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            } else {
                                Text(mealPreference)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 15) {
                        Text("“Eat well, live well.”")
                            .italic()
                            .foregroundColor(.gray)
                    }
                    .padding()

                    Button(isEditing ? "Save Changes" : "Edit Profile") {
                        if isEditing {
                            saveProfileInfo()
                        }
                        isEditing.toggle()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Theme.primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)

                    Button("Sign Out") {
                        authVM.signOut()
                    }
                    .foregroundColor(.red)

                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .onAppear {
                loadProfileInfo()
                fetchUserStats()
            }
        }
    }

    func profileField(label: String, value: Binding<String>) -> some View {
        HStack {
            Text("\(label):").bold()
            if isEditing {
                TextField("Enter \(label.lowercased())", text: value)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                Text(value.wrappedValue.isEmpty ? "Not set" : value.wrappedValue)
            }
        }
    }

    func statCard(title: String, count: Int, systemImage: String) -> some View {
        VStack {
            Image(systemName: systemImage)
                .font(.system(size: 30))
                .foregroundColor(Theme.primaryColor)
            Text("\(count)")
                .font(.title)
                .bold()
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.9))
        .cornerRadius(12)
        .shadow(radius: 3)
    }

    func loadProfileInfo() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let data = document?.data() {
                self.name = data["name"] as? String ?? ""
                self.university = data["university"] as? String ?? ""
                self.major = data["major"] as? String ?? ""
                self.mealPreference = data["mealPreference"] as? String ?? "No Preference"
            }
        }
    }

    func saveProfileInfo() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData([
            "name": name,
            "university": university,
            "major": major,
            "mealPreference": mealPreference
        ], merge: true)
    }

    func fetchUserStats() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("users").document(userId).collection("recipes").getDocuments { snapshot, error in
            if let docs = snapshot?.documents {
                self.savedRecipesCount = docs.count
            }
        }

        db.collection("users").document(userId).collection("mealPlans").getDocuments { snapshot, error in
            if let docs = snapshot?.documents {
                var totalMeals = 0
                for doc in docs {
                    if let meals = doc.data()["meals"] as? [String: [String: String]] {
                        for (_, dailyMeals) in meals {
                            totalMeals += dailyMeals.count
                        }
                    }
                }
                self.mealsPlannedCount = totalMeals
            }
        }
    }
}
