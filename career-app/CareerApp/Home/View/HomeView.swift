import SwiftUI

struct HomeView: View {
    @State private var showFullArticleList = false
    @StateObject var viewModel: HomeViewModel
    private let articleLimit = 10
    @EnvironmentObject private var coordinator: Coordinator
    @StateObject var deepLinkManager = DeepLinkManager()
    
    @State private var searchText = ""
    
    struct Output {
        var goToMainScreen: () -> Void
        var goToForgotPassword: () -> Void
    }
    
    var output: Output
    
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
                        showGithubJobs()
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchHome()
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
    func showArticlesView() -> some View {
        ArticlesHorizontalList(viewModel: viewModel, coordinator: coordinator, showFullArticleList: $showFullArticleList)
    }
    
    @ViewBuilder
    func showNextInterviews() -> some View {
        VStack {
            VStack {
                Text("Próximas Entrevistas")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(Color.titleSectionColor)

                if viewModel.nextJobApplications.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.magnifyingglass")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.persianLightBlue)

                        Text("Nenhuma entrevista próxima cadastrada")
                            .font(.system(size: 16))
                            .foregroundColor(Color.adaptiveBlack)

                        Text("Faça o login para cadastrar\ne consultar entrevistas")
                            .font(.system(size: 14))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.descriptionGray)

                        Button(action: {
                            if let url = URL(string: "https://dev.to/") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("Fazer login")
                                .font(.system(size: 18))
                                .foregroundColor(Color.persianBlue)
                                .shadow(radius: 0.5)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 20)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(viewModel.nextJobApplications, id: \.id) { job in
                                VStack(alignment: .leading, spacing: 8) {
                                    if let nextInterview = job.nextInterview {
                                       
                                        HStack {
                                            Image(systemName: "calendar.badge.clock")
                                                .font(.system(size: 16))
                                                .foregroundColor(Color.persianBlue)
                                        Text(nextInterview)
                                                .font(.system(size: 16))
                                                .bold()
                                                .foregroundColor(Color.persianBlue)
                                        }
                                    }
                                    Text(job.role)
                                        .font(.system(size: 12))
                                        .foregroundColor(Color.secondaryBlue)
                                    Text(job.company)
                                        .font(.system(size: 12))
                                        .foregroundColor(.descriptionGray)
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
                    ForEach(viewModel.jobApplications, id: \.id) { job in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "person.bubble.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.persianBlue)
                                Text(job.role)
                                    .bold()
                                    .font(.system(size: 16))
                                    .foregroundColor(Color.secondaryBlue)
                            }
                            Text((job.company))
                                .font(.system(size: 16))
                                .foregroundColor(.descriptionGray)
                            Text("📆 \(job.nextInterview ?? "N/A")")
                                .font(.system(size: 12))
                                .foregroundColor(.descriptionGray)
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
    func showGithubJobs() -> some View {
        JobHorizontalList(viewModel: viewModel)
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

