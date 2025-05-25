import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: FoodLogViewModel
    @State private var selectedDate = Date()
    @State private var showingImagePicker = false
    @State private var imageData: Data?
    
    init() {
        let apiKey = ""
        _viewModel = StateObject(wrappedValue: FoodLogViewModel(apiKey: apiKey))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select Date",
                          selection: $selectedDate,
                          displayedComponents: [.date])
                    .datePickerStyle(.graphical)
                    .padding()
                
                List {
                    ForEach(viewModel.getFoodItemsForDate(selectedDate)) { item in
                        NavigationLink(destination: FoodDetailView(viewModel: viewModel, foodItem: item)) {
                            FoodItemRow(item: item)
                        }
                    }
                    .onDelete { indices in
                        indices.forEach { index in
                            let items = viewModel.getFoodItemsForDate(selectedDate)
                            viewModel.deleteFoodItem(items[index])
                        }
                    }
                }
            }
            .navigationTitle("Food Log")
            .navigationBarItems(trailing: Button(action: {
                showingImagePicker = true
            }) {
                Image(systemName: "camera")
                    .imageScale(.large)
            })
            .sheet(isPresented: $showingImagePicker) {
                CameraView(imageData: $imageData)
            }
            .onChange(of: imageData) { newValue in
                if let data = newValue {
                    Task {
                        await viewModel.analyzeImage(data)
                        imageData = nil
                    }
                }
            }
        }
    }
}

struct FoodItemRow: View {
    let item: FoodItem
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(item.name)
                .font(.headline)
            Text("\(item.calories) calories")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    ContentView()
} 