import SwiftUI

struct BlogView: View {
    @State private var articles: [Article] = []
    @State private var showFullArticleList = false
    private let articleLimit = 10
    
    @State private var jobApplications = [
        JobApplication(company: "PagBank", level: "Pleno", nextInterview: "18/09/2024", jobTitle: "iOS Developer"),
        JobApplication(company: "Nubank", level: "Sênior", nextInterview: "25/09/2024", jobTitle: "Backend Engineer"),
        JobApplication(company: "Itaú", level: "Júnior", nextInterview: "02/10/2024", jobTitle: "Data Analyst")
    ]
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                Spacer()
                Divider()
                Spacer()
                showNextInterviews()
                showArticlesView()
                showJobApplications()
            }
            .onAppear {
                fetchArticles()
            }
            .toolbarBackground(Color.backgroundLightGray, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    searchField
                }
                ToolbarItem(placement: .automatic) {
                    Text("Home")
                        .font(.title)
                        .bold()
                        .foregroundColor(Color.persianBlue)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    profileButton
                }
            }
        }
    }
    
    @ViewBuilder
    func bla () -> some View {
        if articles.count > articleLimit {
            Button(action: {
                showFullArticleList.toggle()
            }) {
                Text("Ver Mais")
                    .font(.headline)
                    .padding()
                    .frame(width: 200, height: 240)
                    .background(Color.clear)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2)
                    )
            }
            .sheet(isPresented: $showFullArticleList) {
                FullArticleListView(articles: articles)
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    func showArticlesView() -> some View {
        VStack(alignment: .leading) {
            Text("Artigos")
                .font(.title2)
                .bold()
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .center)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(articles.prefix(articleLimit)) { article in
                        ArticleCard(article: article)
                            .frame(width: 200)
                            .onTapGesture {
                                if let url = URL(string: article.url) {
                                    UIApplication.shared.open(url)
                                }
                            }
                    }
                    
                    bla()
                    
                }
//                .padding(.horizontal)
                .padding(.vertical, 10)
            }
//            .padding(.horizontal)
            .cornerRadius(15)
            .shadow(radius: 5)
            
        }
        Spacer()
        Divider()
    }
    
    @ViewBuilder
    func showNextInterviews() -> some View {
        VStack(alignment: .leading) {
            Text("Próximas Entrevistas")
                .font(.title2)
                .bold()
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .center)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(jobApplications) { job in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(job.jobTitle ?? "Sem título")
                                .font(.headline)
                            
                            Text(job.nextInterview ?? "N/A")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(job.company)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(width: 180, height: 120)
                        .background(Color.backgroundLightGray)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                }
//                .padding(.horizontal)
                .padding(.vertical, 10)
            }
//            .padding(.horizontal)
        }
        Spacer()
        Divider()
    }
    
    @ViewBuilder
    func showJobApplications() -> some View {
        VStack(alignment: .leading) {
            Text("Vagas aplicadas")
                .font(.title2)
                .bold()
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .center)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(jobApplications) { job in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(job.jobTitle ?? "Sem título")
                                .font(.headline)
                            
                            Text(job.nextInterview ?? "N/A")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(job.company)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(width: 180, height: 120)
                        .background(Color.backgroundLightGray)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                }
//                .padding(.horizontal)
                .padding(.vertical, 10)
            }
//            .padding(.horizontal)
        }
        Spacer()
        Divider()
    }
    
    private var profileButton: some View {
        Button(action: {
            // Ação do botão de perfil
        }) {
            Image(systemName: "person.circle")
                .resizable()
                .clipShape(Circle())
                .frame(width: 35, height: 35)
                .foregroundColor(Color.persianBlue)
        }
    }
    
    private var searchField: some View {
        HStack {
            ZStack(alignment: .leading) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                
                Spacer()
                
                TextField("Pesquisar", text: $searchText)
                    .padding(.leading, 40)
            }
            .padding(8)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(10)
        }
        .frame(width: 200)
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

struct ArticleCard: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            let coverImageUrl = article.cover_image ?? ""
            if let url = URL(string: coverImageUrl), !coverImageUrl.isEmpty {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 180, height: 100)
                        .clipped()
                        .cornerRadius(10)
                } placeholder: {
                    Image("no-image-available")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 180, height: 100)
                        .clipped()
                        .cornerRadius(10)
                }
            } else {
                Image("no-image-available")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 180, height: 100)
                    .clipped()
                    .cornerRadius(10)
            }
            
            Text(article.title)
                .font(.headline)
                .lineLimit(2)
            
            Text(article.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
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
        .padding()
        .frame(width: 200, height: 240)
        .background(Color.backgroundLightGray)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct BlogViewView_Previews: PreviewProvider {
    static var previews: some View {
        BlogView()
    }
}

