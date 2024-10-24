import SwiftUI

struct BlogView: View {
    @State private var articles: [Article] = []
    
    var body: some View {
        NavigationView {
            List(articles) { article in
                ArticleRow(article: article)
                    .onTapGesture {
                        if let url = URL(string: article.url) {
                            UIApplication.shared.open(url)
                        }
                    }
            }
            .navigationTitle("Blog")
            .onAppear {
                fetchArticles()
            }
        }
    }
    
    private func fetchArticles() {
        guard let url = URL(string: "https://dev.to/api/articles") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            let decoder = JSONDecoder()
            if let fetchedArticles = try? decoder.decode([Article].self, from: data) {
                DispatchQueue.main.async {
                    self.articles = fetchedArticles
                }
            }
        }.resume()
    }
}

struct ArticleRow: View {
    let article: Article
    
    var body: some View {
        HStack(alignment: .top) {
            let coverImageUrl = article.cover_image ?? ""
            if let url = URL(string: coverImageUrl), !coverImageUrl.isEmpty {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                } placeholder: {
                    Image("no-image-available")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                }
            } else {
                Image("no-image-available")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text(article.title)
                    .font(.headline)
                Text(article.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack {
                    Text(article.readable_publish_date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("by \(article.user.name)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.leading, 10)
        }
        .padding(.vertical, 10)
    }
}

