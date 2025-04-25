import Foundation

class RecipeService {
    func loadRecipes() -> [Recipe] {
        guard let url = Bundle.main.url(forResource: "recipes", withExtension: "json") else {
            print("Error: Could not find recipes.json")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let recipes = try JSONDecoder().decode([Recipe].self, from: data)
            print("Successfully loaded \(recipes.count) recipes.")
            return recipes
        } catch {
            print("Error loading recipes: \(error)")
            return []
        }
    }
}
