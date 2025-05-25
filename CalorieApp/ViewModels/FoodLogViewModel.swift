import Foundation
import SwiftUI

@MainActor
class FoodLogViewModel: ObservableObject {
    @Published var foodItems: [FoodItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let openAIService: OpenAIService
    private let userDefaults = UserDefaults.standard
    private let foodItemsKey = "foodItems"
    
    init(apiKey: String) {
        self.openAIService = OpenAIService(apiKey: apiKey)
        loadFoodItems()
    }
    
    private func loadFoodItems() {
        if let data = userDefaults.data(forKey: foodItemsKey),
           let items = try? JSONDecoder().decode([FoodItem].self, from: data) {
            foodItems = items
        }
    }
    
    private func saveFoodItems() {
        if let data = try? JSONEncoder().encode(foodItems) {
            userDefaults.set(data, forKey: foodItemsKey)
        }
    }
    
    func analyzeImage(_ imageData: Data) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let (name, ingredients, calories) = try await openAIService.analyzeImage(imageData)
            let foodItem = FoodItem(name: name,
                                  ingredients: ingredients,
                                  calories: calories,
                                  imageData: imageData)
            foodItems.append(foodItem)
            saveFoodItems()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updateFoodItem(_ item: FoodItem) {
        if let index = foodItems.firstIndex(where: { $0.id == item.id }) {
            foodItems[index] = item
            saveFoodItems()
        }
    }
    
    func deleteFoodItem(_ item: FoodItem) {
        foodItems.removeAll { $0.id == item.id }
        saveFoodItems()
    }
    
    func getFoodItemsForDate(_ date: Date) -> [FoodItem] {
        let calendar = Calendar.current
        return foodItems.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
} 