import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var viewModel: FoodLogViewModel
    @State private var selectedDate = Date()
    @State private var showingImagePicker = false
    @State private var imageData: Data?
    @State private var selectedSource: UIImagePickerController.SourceType?
    @Query private var foodItems: [FoodItem]
    @Environment(\.modelContext) private var modelContext
    
    init() {
        let apiKey = "ENTER_YOUR_API_KEY_HERE"
        _viewModel = StateObject(wrappedValue: FoodLogViewModel(apiKey: apiKey))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    DatePicker("Select Date",
                              selection: $selectedDate,
                              displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .padding()
                    
                    List {
                        ForEach(viewModel.getFoodItemsForDate(selectedDate, items: foodItems)) { item in
                            NavigationLink(destination: FoodDetailView(viewModel: viewModel, foodItem: item)) {
                                FoodItemRow(item: item)
                            }
                        }
                        .onDelete { indices in
                            indices.forEach { index in
                                let items = viewModel.getFoodItemsForDate(selectedDate, items: foodItems)
                                viewModel.deleteFoodItem(items[index], modelContext: modelContext)
                            }
                        }
                    }
                }
                .navigationTitle("Food Log")
                .navigationBarItems(trailing: Menu {
                    Button(action: {
                        selectedSource = .camera
                        showingImagePicker = true
                    }) {
                        Label("Take Photo", systemImage: "camera")
                    }
                    
                    Button(action: {
                        selectedSource = .photoLibrary
                        showingImagePicker = true
                    }) {
                        Label("Choose from Library", systemImage: "photo.on.rectangle")
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.blue)
                })
                
                if viewModel.isLoading {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        
                        Text("Analyzing Image...")
                            .foregroundColor(.white)
                            .padding(.top)
                    }
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                }
            }
            .sheet(isPresented: $showingImagePicker, content: {
                if let sourceType = selectedSource {
                    ImagePickerView(imageData: $imageData, sourceType: sourceType)
                }
            })
            .onChange(of: imageData) { newValue in
                if let data = newValue {
                    Task {
                        await viewModel.analyzeImage(data, modelContext: modelContext)
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
        .modelContainer(for: FoodItem.self, inMemory: true)
} 
