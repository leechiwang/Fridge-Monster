import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe
    @Binding var likedRecipes: [Recipe]
    @State private var isLiked: Bool

    init(recipe: Recipe, likedRecipes: Binding<[Recipe]>) {
        self.recipe = recipe
        self._likedRecipes = likedRecipes
        self._isLiked = State(initialValue: likedRecipes.wrappedValue.contains(where: { $0.id == recipe.id }))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Recipe Image
                Image(recipe.image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)


                // Ingredients Section
                Text("Ingredients")
                    .font(.headline.bold())
                ForEach(recipe.ingredients, id: \.self) { ingredient in
                    Text("• \(ingredient)")
                        .font(.body)
                        .padding(.bottom, 5)
                }

                // Instructions Section
                Text("Instructions")
                    .font(.headline.bold())
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(splitInstructions(), id: \.self) { step in
                        Text(step)
                            .font(.body)
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, 5)
                    }
                }

                // Like Button
                Button(action: toggleLike) {
                    HStack {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(.red)
                        Text(isLiked ? "Unlike" : "Like")
                            .fontWeight(.bold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
        .navigationTitle(recipe.title)
    }

    private func splitInstructions() -> [String] {
        return recipe.instructions
            .components(separatedBy: ". ")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) + ( $0.last == "." ? "" : ".") }
            .filter { !$0.isEmpty }
    }

    private func toggleLike() {
        isLiked.toggle()

        if isLiked {
            likedRecipes.append(recipe)
        } else {
            likedRecipes.removeAll { $0.id == recipe.id }
        }
    }
}
