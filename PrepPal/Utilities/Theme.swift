//
//  Theme.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/21/25.
//

import SwiftUI
import Foundation

struct Theme {
    static let primaryColor = Color.green
    static let backgroundColor = Color.green.opacity(0.1)
    static let fieldBackground = Color(.secondarySystemBackground)
    static let errorColor = Color.red
    
    static func titleFont() -> Font {
        .system(size: 28, weight: .bold, design: .rounded)
    }

    static func subtitleFont() -> Font {
        .system(size: 16, weight: .medium, design: .rounded)
    }

    static func buttonFont() -> Font {
        .system(size: 18, weight: .semibold, design: .rounded)
    }
}

