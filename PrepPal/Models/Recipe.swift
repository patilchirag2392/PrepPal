//
//  Recipe.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/22/25.
//

import Foundation

struct Recipe: Identifiable, Codable {
    var id: String
    var title: String
    var ingredients: String
    var instructions: String
}
