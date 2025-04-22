//
//  LauncherView.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/21/25.
//

import SwiftUI

struct LauncherView: View {
    @State private var showSplash = true
    @EnvironmentObject var authVM: AuthViewModel

    var body: some View {
        Group {
            if authVM.isAuthenticated {
                ContentView()
            } else {
                if showSplash {
                    SplashView()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showSplash = false
                                }
                            }
                        }
                } else {
                    AuthView()
                }
            }
        }
        .environmentObject(authVM)
    }
}
