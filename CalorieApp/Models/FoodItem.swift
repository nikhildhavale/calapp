import Foundation
import SwiftData

@Model
final class FoodItem {
    var id: UUID
    var name: String
    var ingredients: [String]
    var calories: Int
    var imageData: Data?
    var date: Date
    var notes: String?
    
    init(name: String = "", ingredients: [String] = [], calories: Int = 0, imageData: Data? = nil, notes: String? = nil) {
        self.id = UUID()
        self.name = name
        self.ingredients = ingredients
        self.calories = calories
        self.imageData = imageData
        self.date = Date()
        self.notes = notes
    }
} 