import SwiftUI

struct TodoItem: Identifiable, Codable {
    var id = UUID()
    let task: String
}

class TodoListViewModel: ObservableObject {
    @Published var items: [TodoItem] = []
    @Published var selectedTheme: UIUserInterfaceStyle = .light
    
    init() {
        loadItems()
        loadTheme()
    }
    
    func addItem(task: String) {
        let newItem = TodoItem(task: task)
        items.append(newItem)
        saveItems()
    }
    
    func removeItem(at indexSet: IndexSet) {
        items.remove(atOffsets: indexSet)
        saveItems()
    }
    
    func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: "TodoListItems")
        }
    }
    
    func loadItems() {
        if let data = UserDefaults.standard.data(forKey: "TodoListItems"),
           let decoded = try? JSONDecoder().decode([TodoItem].self, from: data) {
            items = decoded
        }
    }
    
    func saveTheme() {
        UserDefaults.standard.set(selectedTheme.rawValue, forKey: "SelectedTheme")
    }
    
    func loadTheme() {
        if let themeRawValue = UserDefaults.standard.value(forKey: "SelectedTheme") as? Int,
           let theme = UIUserInterfaceStyle(rawValue: themeRawValue) {
            selectedTheme = theme
        }
    }
}

struct TodoListView: View {
    @ObservedObject var viewModel: TodoListViewModel
    @State private var newTask = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter a new task", text: $newTask)
                    .padding()
                Button(action: {
                    viewModel.addItem(task: newTask)
                    newTask = ""
                }) {
                    Text("Add Task")
                }
                List {
                    ForEach(viewModel.items) { item in
                        Text(item.task)
                    }
                    .onDelete(perform: viewModel.removeItem)
                }
            }
            .navigationTitle("Todo List")
            .navigationBarItems(trailing: ThemeButton(viewModel: viewModel))
        }
        .environment(\.colorScheme, viewModel.selectedTheme == .dark ? .dark : .light)
    }
}

struct ThemeButton: View {
    @ObservedObject var viewModel: TodoListViewModel
    
    var body: some View {
        Button(action: {
            let newTheme: UIUserInterfaceStyle = viewModel.selectedTheme == .dark ? .light : .dark
            viewModel.selectedTheme = newTheme
            viewModel.saveTheme()
        }) {
            Image(systemName: viewModel.selectedTheme == .dark ? "sun.max.fill" : "moon.fill")
                .foregroundColor(.primary)
                .font(.title)
        }
    }
}

struct ContentView: View {
    var body: some View {
        let viewModel = TodoListViewModel()
        TodoListView(viewModel: viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

