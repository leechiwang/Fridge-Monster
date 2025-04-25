import SwiftUI

import SwiftUI

struct SearchResultsView: View {
    @Binding var recipes: [Recipe]
    @Binding var likedRecipes: [Recipe]

    var body: some View {
        VStack {
            Text("Search Results")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            if recipes.isEmpty {
                Text("No matching recipes found.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(recipes, id: \.id) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe, likedRecipes: $likedRecipes)) {
                        RecipeRow(recipe: recipe)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationBarTitle("Recipes", displayMode: .inline)
    }
}
