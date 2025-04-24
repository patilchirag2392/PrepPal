//
//  EditProfileSheet.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/24/25.
//

import SwiftUI

struct EditProfileSheet: View {
    @Binding var userName: String
    @Binding var university: String

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Info")) {
                    TextField("Name", text: $userName)
                    TextField("University", text: $university)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
