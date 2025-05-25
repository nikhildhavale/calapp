import Foundation

struct FoodItem: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var ingredients: [String]
    var calories: Int
    var imageData: Data?
    var date: Date
    var notes: String?
    
    init(name: String = "", ingredients: [String] = [], calories: Int = 0, imageData: Data? = nil, notes: String? = nil) {
        self.name = name
        self.ingredients = ingredients
        self.calories = calories
        self.imageData = imageData
        self.date = Date()
        self.notes = notes
    }
} 