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
        print("🔑 OpenAIService initialized with API key: \(apiKey.prefix(8))...")
    }
    
    func analyzeImage(_ imageData: Data) async throws -> (name: String, ingredients: [String], calories: Int) {
        print("📸 Starting image analysis...")
        print("📦 Image data size: \(ByteCountFormatter.string(fromByteCount: Int64(imageData.count), countStyle: .file))")
        
        guard !imageData.isEmpty else {
            print("❌ Error: Image data is empty")
            throw OpenAIError.invalidImageData
        }
        
        let base64Image = imageData.base64EncodedString()
        print("🔄 Converted image to base64 string")
        
        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "Analyze this food image and provide: 1. Food name 2. List of ingredients 3. Estimated calories. Format as JSON with fields: name, ingredients (array), calories (number). Return only the JSON, no markdown."
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
            print("🚀 Sending request to OpenAI API...")
            var request = URLRequest(url: URL(string: baseURL)!)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Error: Invalid response type")
                throw OpenAIError.invalidResponse
            }
            
            print("📡 Received response with status code: \(httpResponse.statusCode)")
            
            if !(200...299).contains(httpResponse.statusCode) {
                print("❌ Error: HTTP status code \(httpResponse.statusCode)")
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("Error details: \(errorJson)")
                }
                throw OpenAIError.invalidResponse
            }
            
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            print("✅ Successfully decoded OpenAI response")
            
            if let content = openAIResponse.choices.first?.message.content {
                print("📝 Raw response content: \(content)")
                
                // Clean up the content by removing markdown code blocks if present
                let cleanContent = content
                    .replacingOccurrences(of: "```json\n", with: "")
                    .replacingOccurrences(of: "```\n", with: "")
                    .replacingOccurrences(of: "```", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                print("🧹 Cleaned content: \(cleanContent)")
                
                guard let jsonData = cleanContent.data(using: .utf8),
                      let result = try? JSONDecoder().decode(FoodAnalysis.self, from: jsonData) else {
                    print("❌ Error: Failed to parse response JSON")
                    print("Response content that couldn't be parsed: \(cleanContent)")
                    throw OpenAIError.parsingError
                }
                
                print("✨ Successfully parsed food analysis:")
                print("🍽 Food name: \(result.name)")
                print("📋 Ingredients: \(result.ingredients.joined(separator: ", "))")
                print("🔢 Calories: \(result.calories)")
                
                return (result.name, result.ingredients, result.calories)
            } else {
                print("❌ Error: No content in response choices")
                throw OpenAIError.parsingError
            }
        } catch {
            if let openAIError = error as? OpenAIError {
                print("❌ OpenAI Error: \(openAIError)")
                throw openAIError
            }
            print("❌ Network Error: \(error.localizedDescription)")
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

extension ByteCountFormatter {
    static func string(fromByteCount byteCount: Int64, countStyle: ByteCountFormatter.CountStyle) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = countStyle
        return formatter.string(fromByteCount: byteCount)
    }
} 