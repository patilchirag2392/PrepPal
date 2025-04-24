//
//  AIService.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/23/25.
//

import Foundation

class AIService {
    static let shared = AIService()
    private init() {}

    let apiKey = "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"

    func getMealSuggestions(from recipes: [Recipe], completion: @escaping (Result<[String: [String: String]], Error>) -> Void) {
        print("📡 Preparing AI Request with recipes: \(recipes.map { $0.title })")
        let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!

        let recipeTitles = recipes.isEmpty ? "pasta, salad, smoothie, sandwich" : recipes.map { $0.title }.joined(separator: ", ")
        let prompt = "Suggest a weekly meal plan with Breakfast, Lunch, and Dinner for 7 days using recipes like: \(recipeTitles). Return it in JSON format with days as keys and each day containing Breakfast, Lunch, and Dinner."

        let json: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a helpful meal planner."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7
        ]

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data", code: -1)))
                }
                return
            }

            do {
                let jsonString = String(data: data, encoding: .utf8)
                print("🔍 Raw AI Response: \(jsonString ?? "No response body")")
                
                if let result = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = result["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    
                    print("📋 AI Message Content: \(content)")
                    
                    // Try parsing content into JSON
                    if let planData = content.data(using: .utf8),
                       let plan = try? JSONSerialization.jsonObject(with: planData) as? [String: [String: String]] {
                        DispatchQueue.main.async {
                            completion(.success(plan))
                        }
                    } else {
                        print("⚠️ Failed to parse JSON from AI content.")
                        DispatchQueue.main.async {
                            completion(.failure(NSError(domain: "Parsing error", code: -2)))
                        }
                    }

                } else {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "Invalid response", code: -3)))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
