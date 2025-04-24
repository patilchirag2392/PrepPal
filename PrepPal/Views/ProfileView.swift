//
//  ProfileView.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/24/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var university: String = ""
    @State private var major: String = ""
    @State private var isSaving: Bool = false
    @State private var saveSuccess: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(Auth.auth().currentUser?.email ?? "Email not available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 10) {
                    Text("University")
                        .font(.headline)
                    TextField("Enter your university", text: $university)
                        .padding()
                        .background(Theme.fieldBackground)
                        .cornerRadius(10)
                    Text("Saved: \(university)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Major")
                        .font(.headline)
                    TextField("Enter your major", text: $major)
                        .padding()
                        .background(Theme.fieldBackground)
                        .cornerRadius(10)
                    Text("Saved: \(major)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Button(action: saveProfileInfo) {
                    Text(isSaving ? "Saving..." : "Save Profile")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Theme.primaryColor)
                        .cornerRadius(12)
                }
                .disabled(isSaving)

                if saveSuccess {
                    Text("Profile saved successfully!")
                        .foregroundColor(.green)
                        .font(.footnote)
                        .transition(.opacity)
                }

                Spacer()

                Button(action: {
                    authVM.signOut()
                }) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray5))
                        .cornerRadius(12)
                }
                .padding(.bottom)
            }
            .padding()
            .background(Theme.backgroundColor.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: loadProfileInfo)
        }
    }

    func loadProfileInfo() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let data = document?.data() {
                self.university = data["university"] as? String ?? ""
                self.major = data["major"] as? String ?? ""
            }
        }
    }

    func saveProfileInfo() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isSaving = true
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData([
            "university": university,
            "major": major
        ], merge: true) { error in
            isSaving = false
            if let error = error {
                print("Error saving profile: \(error.localizedDescription)")
                saveSuccess = false
            } else {
                saveSuccess = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    saveSuccess = false
                }
            }
        }
    }
}
