import Foundation

enum OpenAIError: Error {
    case invalidImageData
    case invalidResponse
    case networkError(Error)
    case parsingError
}

class OpenAIService {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func analyzeImage(_ imageData: Data) async throws -> (name: String, ingredients: [String], calories: Int) {
        guard !imageData.isEmpty else {
            throw OpenAIError.invalidImageData
        }
        
        let base64Image = imageData.base64EncodedString()
        
        let requestBody: [String: Any] = [
            "model": "gpt-4-vision-preview",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "Analyze this food image and provide: 1. Food name 2. List of ingredients 3. Estimated calories. Format as JSON with fields: name, ingredients (array), calories (number)"
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 500
        ]
        
        do {
            var request = URLRequest(url: URL(string: baseURL)!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw OpenAIError.invalidResponse
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            
            guard let content = openAIResponse.choices.first?.message.content,
                  let jsonData = content.data(using: .utf8),
                  let result = try? JSONDecoder().decode(FoodAnalysis.self, from: jsonData) else {
                throw OpenAIError.parsingError
            }
            
            return (result.name, result.ingredients, result.calories)
        } catch {
            if error is OpenAIError {
                throw error
            }
            throw OpenAIError.networkError(error)
        }
    }
}

// Response models
struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}

struct FoodAnalysis: Codable {
    let name: String
    let ingredients: [String]
    let calories: Int
} 