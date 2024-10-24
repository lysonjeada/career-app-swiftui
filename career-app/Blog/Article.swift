struct Article: Identifiable, Decodable {
    let id: Int
    let title: String
    let description: String
    let readable_publish_date: String
    let url: String
    let cover_image: String?
    let user: User
}

struct User: Decodable {
    let name: String
    let profile_image: String
}
