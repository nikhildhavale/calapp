import Foundation
import SwiftUI
import SwiftData

@MainActor
class FoodLogViewModel: ObservableObject {
    @Published var foodItems: [FoodItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let openAIService: OpenAIService
    private var errorDismissTask: Task<Void, Never>?
    
    init(apiKey: String) {
        self.openAIService = OpenAIService(apiKey: apiKey)
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
    
    func analyzeImage(_ imageData: Data, modelContext: ModelContext) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let (name, ingredients, calories) = try await openAIService.analyzeImage(imageData)
            let foodItem = FoodItem(name: name,
                                  ingredients: ingredients,
                                  calories: calories,
                                  imageData: imageData)
            modelContext.insert(foodItem)
            try modelContext.save()
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
    
    func updateFoodItem(_ item: FoodItem, modelContext: ModelContext) {
        try? modelContext.save()
    }
    
    func deleteFoodItem(_ item: FoodItem, modelContext: ModelContext) {
        modelContext.delete(item)
        try? modelContext.save()
    }
    
    func getFoodItemsForDate(_ date: Date, items: [FoodItem]) -> [FoodItem] {
        let calendar = Calendar.current
        return items.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    deinit {
        errorDismissTask?.cancel()
    }
} 