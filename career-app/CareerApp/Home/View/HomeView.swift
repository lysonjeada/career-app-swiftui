import SwiftUI

struct HomeView: View {
    @State private var showFullArticleList = false
    @StateObject var viewModel: HomeViewModel
    private let articleLimit = 10
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject var deepLinkManager = DeepLinkManager()
    
    @State private var jobApplications = [
        JobApplication(company: "PagBank", level: "Pleno", nextInterview: "18/09/2024", jobTitle: "iOS Developer"),
        JobApplication(company: "Nubank", level: "Sênior", nextInterview: "25/09/2024", jobTitle: "Backend Engineer"),
        JobApplication(company: "Itaú", level: "Júnior", nextInterview: "02/10/2024", jobTitle: "Data Analyst")
    ]
    
    @State private var searchText = ""
    
    struct Output {
        var goToMainScreen: () -> Void
        var goToForgotPassword: () -> Void
    }
    
    var output: Output
    
    private var profileButton: some View {
        NavigationLink(destination: ProfileView()) {
            Image(systemName: "person.circle")
                .resizable()
                .clipShape(Circle())
                .frame(width: 28, height: 28)
                .foregroundColor(Color.persianBlue)
        }
    }
    
    var body: some View {
        VStack {
            switch viewModel.viewState {
            case .loading:
                ScrollView {
                    VStack {
                        buildJobsLoading()
                        buildArticlesLoading()
                        buildJobsLoading()
                        buildCarouselLoading()
                    }
                }
            case .loaded:
                ScrollView {
                    VStack(spacing: 16) {
                        Divider()
                            .background(Color.gray.opacity(0.3))
                        showNextInterviews()
                        showArticlesView()
                        showJobApplication()
                        showJobApplications()
                    }
                }
                
            }
            
        }
        
        .onAppear {
            viewModel.fetchArticles()
        }
        
    }
    
    @ViewBuilder
    func buildHomeView() -> some View {
        
    }
    
    @ViewBuilder
    func buildArticlesLoading() -> some View {
        LoadingCard(style: .article, title: "Artigos")
    }
    
    @ViewBuilder
    func buildJobsLoading() -> some View {
        LoadingCard(style: .job, title: "Próximas Entrevistas")
    }
    
    @ViewBuilder
    func buildCarouselLoading() -> some View {
        LoadingCard(style: .carousel, title: nil)
    }
    
    @ViewBuilder
    func buildShowMoreButton() -> some View {
        if viewModel.articles.count > articleLimit {
            Button(action: {
                showFullArticleList.toggle()
            }) {
                Text("Ver Mais")
                    .font(.headline)
                    .padding()
                    .frame(width: 120, height: 120)
                    .background(Color.clear)
                    .foregroundColor(Color.persianBlue)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 60)
                            .stroke(Color.persianBlue, lineWidth: 2)
                    )
            }
            .padding(.trailing, 16)
            .shadow(radius: 1)
            .sheet(isPresented: $showFullArticleList) {
                FullArticleListView(articles: viewModel.articles)
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    func showArticlesView() -> some View {
        VStack(alignment: .leading) {
            VStack(alignment: .center) {
                Text("Artigos")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color.titleSectionColor)
                    .padding(.bottom, 1)
                
                Button(action: {
                    let stringURL = "https://dev.to/"
                    if let url = URL(string: stringURL) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Text("Abrir dev.to")
                            .font(.system(size: 12))
                            .foregroundColor(Color.persianBlue)
                            .shadow(radius: 0.5)
                        Image(systemName: "plus.magnifyingglass")
                            .font(.system(size: 12))
                            .foregroundColor(Color.persianBlue)
                            .shadow(radius: 0.5)
                    }
                }
            }
            
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(viewModel.articles.prefix(articleLimit)) { article in
                        ArticleCard(article: article)
                            .frame(width: 200)
                            .padding(.vertical, 2)
                            .onTapGesture {
                                //TODO: Chamar um metodo na view model que abra uma view de detalhes com nome, imagem maior e texto com scroll view
                                coordinator.push(page: .articleDetail(id: article.id))
                                //                                viewModel.goToArticleDetail(articleId: article.id)
                                //                                if let url = URL(string: article.url) {
                                //                                    UIApplication.shared.open(url)
                                //                                }
                            }
                    }
                    buildShowMoreButton()
                }
            }
            .padding(.top, 2)
            .cornerRadius(15)
            //            .shadow(radius: 5)
            
        }
        Divider()
    }
    
    @ViewBuilder
    func showNextInterviews() -> some View {
        VStack {
            VStack(alignment: .leading) {
                Text("Próximas Entrevistas")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color.titleSectionColor)
                if !coordinator.isLoggedIn {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(jobApplications) { job in
                                VStack(alignment: .leading, spacing: 8) {
                                    if let nextInterview = job.nextInterview,
                                       let formattedDate = formatDate(nextInterview) {
                                        HStack {
                                            Image(systemName: "calendar.badge.clock")
                                                .font(.system(size: 16))
                                                .foregroundColor(Color.persianBlue)
                                            Text(formattedDate)
                                                .font(.system(size: 16))
                                                .bold()
                                                .foregroundColor(Color.persianBlue)
                                        }
                                    } else {
                                        Text("N/A")
                                            .font(.system(size: 16))
                                            .bold()
                                            .foregroundColor(Color.persianBlue)
                                    }
                                    Text(job.jobTitle ?? "Sem título")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.secondaryBlue)
                                    Text(job.company)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 24)
                                .padding(.horizontal, 20)
                                .background(Color.backgroundLightGray)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
            }
            if coordinator.isLoggedIn {
                VStack(alignment: .center) {
                    Image(systemName: "exclamationmark.magnifyingglass")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.persianLightBlue)
                    Text("Nenhuma entrevista cadastrada")
                        .font(.system(size: 16))
                        .foregroundColor(Color.black)
                        .padding(.bottom, 4)
                    Text("Faça o login para cadastrar\ne consultar entrevistas")
                        .font(.system(size: 14))
                        .foregroundColor(Color.descriptionGray)
                        .padding(.bottom, 8)
                    Button(action: {
                        let stringURL = "https://dev.to/"
                        if let url = URL(string: stringURL) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        
                        Text("Fazer login")
                            .font(.system(size: 18))
                            .foregroundColor(Color.persianBlue)
                            .shadow(radius: 0.5)
                        
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
            }

            //            .padding(.horizontal)
        }
        
        Divider()
    }
    
    @ViewBuilder
    func showJobApplication() -> some View {
        VStack(alignment: .leading) {
            Text("Vagas aplicadas")
                .font(.title2)
                .bold()
                .padding(.top, 4)
                .frame(maxWidth: .infinity, alignment: .center)
                .foregroundColor(Color.titleSectionColor)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(jobApplications) { job in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "person.bubble.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.persianBlue)
                                Text(job.jobTitle ?? "Sem título")
                                    .bold()
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.secondaryBlue)
                            }
                            Text(job.company)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                            Text(job.nextInterview ?? "N/A")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(Color.backgroundLightGray)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                }
                .padding(.vertical, 10)
            }
        }
        
        Divider()
    }
    
    @ViewBuilder
    func showJobApplications() -> some View {
        VStack {
            AutoScroller(
                items: [
                    CarouselItem(
                        image: "resume-image",
                        description: "Gere dicas e otimize seu curriculo a partir do seu currículo do LinkedIN",
                        buttonTitle: "Faça o download do seu currículo",
                        action: { print("Resume button tapped") }
                    ),
                    CarouselItem(
                        cardType: CarouselItem.CardType.leading,
                        image: "generate-image",
                        description: "Generate interview questions tailored to your skills.",
                        buttonTitle: "Generate Now",
                        action: { print("Generate button tapped") }
                    ),
                    CarouselItem(
                        image: "generate-resume",
                        description: "Explore our tools to help you achieve career success.",
                        buttonTitle: "Explore",
                        action: { print("Explore button tapped") }
                    )
                ])
        }
        
        
        Divider()
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
    
    func formatDate(_ dateString: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd/MM/yyyy"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd/MM"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return nil
    }
}



struct BlogViewView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewModel: HomeViewModel(), output: .init(goToMainScreen: { }, goToForgotPassword: { }))
    }
}

