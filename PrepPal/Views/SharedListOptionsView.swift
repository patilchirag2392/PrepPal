//
//  SharedListOptionsView.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/23/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SharedListOptionsView: View {
    @Binding var sharedListId: String?
    @Binding var isUsingSharedList: Bool
    var onListJoined: (String) -> Void

    @State private var inputCode = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Button("Create New Shared List") {
                    createSharedList()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Theme.primaryColor)
                .cornerRadius(10)

                Divider()

                TextField("Enter Shared List Code", text: $inputCode)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Join Shared List") {
                    joinSharedList(with: inputCode)
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Theme.primaryColor)
                .cornerRadius(10)
            }
            .padding()
            .navigationTitle("Shared List Options")
//            .navigationBarItems(trailing:
//                Button("Cancel") {
//                    isUsingSharedList = false
//                }
//            )
        }
    }

    func createSharedList() {
        let newListId = UUID().uuidString
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("sharedLists").document(newListId).setData([
            "items": [],
            "members": [userId]
        ]) { error in
            if error == nil {
                print("🔗 Shared List ID: \(newListId)") // 👈 Add this line
                onListJoined(newListId)
            }
        }
    }

    func joinSharedList(with code: String) {
        let db = Firestore.firestore()
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let docRef = db.collection("sharedLists").document(code)
        docRef.getDocument { document, error in
            if let document = document, document.exists {
                docRef.updateData([
                    "members": FieldValue.arrayUnion([userId])
                ]) { error in
                    if error == nil {
                        onListJoined(code)
                    }
                }
            } else {
                print("Shared List Not Found")
            }
        }
    }
}
