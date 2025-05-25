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
    private var errorDismissTask: Task<Void, Never>?
    
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
    
    private func showError(_ message: String) {
        errorMessage = message
        // Cancel any existing error dismiss task
        errorDismissTask?.cancel()
        
        // Create a new task to dismiss the error after 3 seconds
        errorDismissTask = Task {
            try? await Task.sleep(nanoseconds: 3 * 1_000_000_000) // 3 seconds
            if !Task.isCancelled {
                errorMessage = nil
            }
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
        } catch OpenAIError.invalidImageData {
            showError("The image could not be processed. Please try taking the photo again.")
        } catch OpenAIError.invalidResponse {
            showError("There was a problem communicating with the server. Please try again.")
        } catch OpenAIError.parsingError {
            showError("Could not understand the response from the server. Please try again.")
        } catch OpenAIError.networkError {
            showError("Network error occurred. Please check your internet connection and try again.")
        } catch {
            showError(error.localizedDescription)
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
    
    deinit {
        errorDismissTask?.cancel()
    }
} 