import SwiftUI

struct ContentView: View {
    @State private var newIngredient: String = ""
    @State private var ingredients: [Ingredient] = [
        Ingredient(name: "Tomato", image: "tomato"),
        Ingredient(name: "Cheese", image: "cheese"),
        Ingredient(name: "Egg", image: "egg"),
        Ingredient(name: "Onion", image: "onion"),
        Ingredient(name: "Chicken", image: "chicken"),
        Ingredient(name: "Milk", image: "milk"),
        Ingredient(name: "Bread", image: "bread"),
        Ingredient(name: "Pork", image: "pork")
    ]
    @State private var selectedIngredients: [String] = []
    @State private var recipes: [Recipe] = []
    @State private var likedRecipes: [Recipe] = []
    @State private var navigateToResults = false
    private let recipeService = RecipeService()

    var body: some View {
        TabView {
            NavigationView {
                VStack {
                    headerView()
                    ScrollView {
                        ingredientGridView()
                    }
                    searchButton()

                    //recipeListView()
                }
                //.navigationTitle("Fridge Monster")
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")
            }

            // Favorites tab
            NavigationView {
                List(likedRecipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe, likedRecipes: $likedRecipes)) {
                        RecipeRow(recipe: recipe)
                    }
                }
                .navigationTitle("Favorites")
            }
            .tabItem {
                Label("Favorites", systemImage: "heart.fill")
            }
        }
    }

    // MARK: - Subviews

    private func headerView() -> some View {
        VStack(alignment: .leading) {
            Text("What's in your fridge?")
                .font(.title)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top, 30)
            


            HStack {
                TextField("Enter ingredient", text: $newIngredient)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button(action: addIngredient) {
                    Text("Add")
                        .padding()
                        .frame(width: 120, height: 50)
                        .background(Color.pink)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .fontWeight(.bold)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

    private func ingredientGridView() -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            ForEach(ingredients) { ingredient in
                Button(action: {
                    toggleSelection(of: ingredient)
                }) {
                    ingredientView(for: ingredient)
                }
            }
        }
        .padding(.horizontal)
    }

    private func searchButton() -> some View {
        VStack {
            Button(action: {
                searchRecipes()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    navigateToResults = true
                }
            }) {
                Text("Search")
                    .padding()
                    .frame(width: 220, height: 50)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .fontWeight(.bold)
            }
            

            
            // NavigationLink that only activates when navigateToResults is true
            NavigationLink(destination: SearchResultsView(recipes: $recipes, likedRecipes: $likedRecipes),
                           isActive: $navigateToResults) {
                EmptyView()
            }
        }
    }



    private func recipeListView() -> some View {
        VStack {
            if !recipes.isEmpty {
                List(recipes, id: \.id) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe, likedRecipes: $likedRecipes)) {
                        RecipeRow(recipe: recipe)
                    }
                }
                .listStyle(PlainListStyle())
            } else {
                Text(selectedIngredients.isEmpty ? "Select ingredients to find recipes" : "No matching recipes found.")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
    }

    // MARK: - Helper Views

    private func ingredientView(for ingredient: Ingredient) -> some View {
        VStack {
            if let imageName = UIImage(named: ingredient.image) {
                Image(ingredient.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
            }

            Text(ingredient.name.capitalized)
                .font(.headline)
        }
        .padding()
        .background(backgroundColor(for: ingredient))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor(for: ingredient), lineWidth: 4)
        )
    }

    private func backgroundColor(for ingredient: Ingredient) -> Color {
        selectedIngredients.contains(ingredient.name) ? Color(red: 0.4627, green: 0.8392, blue: 1.0).opacity(0.2) : Color.clear
    }

    private func borderColor(for ingredient: Ingredient) -> Color {
        selectedIngredients.contains(ingredient.name) ? Color(red: 0.4627, green: 0.8392, blue: 1.0) : Color.clear
    }

    // MARK: - Actions

    private func addIngredient() {
        let trimmedIngredient = newIngredient.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmedIngredient.isEmpty, !selectedIngredients.contains(trimmedIngredient) else {
            return
        }
        let imageName = UIImage(named: trimmedIngredient.lowercased()) != nil ? trimmedIngredient.lowercased() : "placeholder"
                
        // Add new ingredient with correct image or placeholder
        ingredients.append(Ingredient(name: trimmedIngredient, image: imageName))
        selectedIngredients.append(trimmedIngredient)
        newIngredient = ""
    }

    private func toggleSelection(of ingredient: Ingredient) {
        if selectedIngredients.contains(ingredient.name) {
            selectedIngredients.removeAll { $0 == ingredient.name }
        } else {
            selectedIngredients.append(ingredient.name)
        }
    }

    private func searchRecipes() {
        print("Selected ingredients: \(selectedIngredients)")

        let allRecipes = recipeService.loadRecipes()

        if allRecipes.isEmpty {
            recipes = [] // Ensure it updates with an empty list
            return
        }

        let normalizedSelectedIngredients = Set(selectedIngredients.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })

        // Filter recipes that ONLY contain selected ingredients (but user can have more)
        let filteredRecipes = allRecipes.filter { recipe in
            let normalizedRecipeIngredients = Set(recipe.ingredients.map { $0.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) })
            let isSubset = normalizedRecipeIngredients.isSubset(of: normalizedSelectedIngredients)
            
            print("🔹 Checking Recipe: \(recipe.title)")
            print("   - Ingredients: \(normalizedRecipeIngredients)")
            print("   - Matches Selection: \(isSubset)")

            return isSubset
        }

        DispatchQueue.main.async {
            self.recipes = filteredRecipes
        }

    }



}

// Custom Recipe Row
struct RecipeRow: View {
    let recipe: Recipe

    var body: some View {
        HStack {
            if let _ = UIImage(named: recipe.image) {
                Image(recipe.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .cornerRadius(8)
                    .foregroundColor(.gray)
            }

            VStack(alignment: .leading) {
                Text(recipe.title)
                    .font(.headline)

                Text("\(recipe.ingredients.count) ingredients")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
    }
}
