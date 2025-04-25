//
//  SplashView.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/21/25.
//

import SwiftUI
import Foundation

struct SplashView: View {
    @State private var isActive = false

    var body: some View {
        ZStack {
            Theme.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                Image("icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(100)

                Text("PrepPal")
                    .font(Theme.titleFont())
                    .foregroundColor(Theme.primaryColor)

                Spacer()

                Text("Your smart meal planning buddy 🍽️")
                    .font(Theme.subtitleFont())
                    .foregroundColor(.gray)
                    .padding(.bottom, 20) 
            }
            .padding(.horizontal, 30)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isActive = true
                }
            }
        }
        .transition(.opacity)
        .fullScreenCover(isPresented: $isActive) {
            AuthView()
                .environmentObject(AuthViewModel())
        }
    }
}
