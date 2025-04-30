//
//  LocalLLMService.swift
//  PrepPal
//
//  Created by Chirag Patil on 4/24/25.
//

import Foundation

class LocalLLMService {
    static let shared = LocalLLMService()
    private init() {}

    func getMealSuggestions(prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = URL(string: "http://localhost:11434/api/generate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let json: [String: Any] = [
            "model": "llama2:latest",
            "prompt": prompt,
            "stream": false
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120
        config.timeoutIntervalForResource = 120
        
        let session = URLSession(configuration: config)

        session.dataTask(with: request) { data, response, error in
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

            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let responseText = result["response"] as? String {
                DispatchQueue.main.async {
                    completion(.success(responseText))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "Invalid data", code: -2)))
                }
            }
        }.resume()
    }
}
