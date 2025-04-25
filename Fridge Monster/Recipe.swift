import Foundation

struct Recipe: Identifiable, Codable {
    let id: String
    let title: String
    let image: String
    let ingredients: [String]
    let instructions: String
    var isLiked: Bool? = false 
}

