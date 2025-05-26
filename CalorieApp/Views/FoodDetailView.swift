import SwiftUI
import SwiftData

struct FoodDetailView: View {
    @ObservedObject var viewModel: FoodLogViewModel
    @Bindable var foodItem: FoodItem
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Form {
            Section(header: Text("Food Image")) {
                if let imageData = foodItem.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                }
            }
            
            Section(header: Text("Details")) {
                TextField("Food Name", text: $foodItem.name)
                
                HStack {
                    Text("Calories")
                    Spacer()
                    TextField("Calories", value: $foodItem.calories, format: .number)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            Section(header: Text("Ingredients")) {
                ForEach(foodItem.ingredients.indices, id: \.self) { index in
                    TextField("Ingredient", text: $foodItem.ingredients[index])
                }
                .onDelete { indices in
                    foodItem.ingredients.remove(atOffsets: indices)
                }
                
                Button("Add Ingredient") {
                    foodItem.ingredients.append("")
                }
            }
            
            Section(header: Text("Notes")) {
                TextEditor(text: Binding(
                    get: { foodItem.notes ?? "" },
                    set: { foodItem.notes = $0.isEmpty ? nil : $0 }
                ))
                .frame(height: 100)
            }
        }
        .navigationTitle("Food Details")
        .navigationBarItems(trailing: Button("Save") {
            viewModel.updateFoodItem(foodItem, modelContext: modelContext)
            presentationMode.wrappedValue.dismiss()
        })
    }
} 