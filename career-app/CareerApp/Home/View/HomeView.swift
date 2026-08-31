import SwiftUI

struct HomeView: View {
    @State private var showFullArticleList = false
    @ObservedObject var viewModel: HomeViewModel
    private let articleLimit = 10
    @EnvironmentObject private var coordinator: Coordinator

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
                    VStack(spacing: 16) {
                        Divider()
                            .background(Color.gray.opacity(0.3))
                        buildNextInterviewsLoading()
                        buildArticlesLoading()
                        buildJobsAppliedLoading()
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
                        if !viewModel.videos.isEmpty {
                            HomeVideosCarousel(
                                videos:
                                    viewModel.videos
                            ) { video in

                                coordinator.videos.push(
                                    .videoDetail(
                                        videoId:
                                            video.id
                                    )
                                )
                            }
                        }
                    }
                }
            case .error:
                VStack {
                    Image("error-image")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .padding(.top, 24)
                    Text("Não foi possível carregar o conteúdo.\nTente novamente mais tarde.")
                    Spacer()
                    PrimaryButton(title: "Tentar novamente", action: viewModel.tryAgain)
                    
                }
            }
        }
        .navigationBarBackButtonHidden(true)
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
    func buildNextInterviewsLoading() -> some View {
        LoadingCard(style: .job, title: "Próximas Entrevistas")
    }
    
    @ViewBuilder
    func buildJobsAppliedLoading() -> some View {
        LoadingCard(style: .job, title: "Vagas aplicadas")
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
                    .textHomeStyle()
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.titleSectionColor)
                
                if viewModel.nextJobApplications.isEmpty {
                    buildEmptyInterviewList(isNextInterview: true)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(viewModel.nextJobApplications, id: \.id) { job in
                                buildDateCard(with: job)
                                    .onTapGesture {
                                        coordinator.track.push(.editJob(job))
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
        VStack {
            Text("Vagas aplicadas")
                .textHomeStyle()
                .padding(.top, 4)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.titleSectionColor)
            
            if viewModel.jobApplications.isEmpty {
                buildEmptyInterviewList(isNextInterview: false)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(viewModel.jobApplications, id: \.id) { job in
                            buildCard(with: job)
                                .onTapGesture {
                                    coordinator.track.push(.editJob(job))
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
        }
        
        Divider()
    }
    
    @ViewBuilder
    private func buildDateCard(with job: JobApplication) -> some View {
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
    }
    
    @ViewBuilder
    private func buildCard(with job: JobApplication) -> some View {
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
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.gray)
                
                Text(job.nextInterview ?? "A definir")
                    .font(.system(size: 12))
                    .foregroundColor(.descriptionGray)
            }
            
        }
    }
    
    @ViewBuilder
    private func buildEmptyInterviewList(isNextInterview: Bool) -> some View {
        if viewModel.isAuthenticated {
            EmptyInterviewListView(
                action: {
                    coordinator.track.push(.addJob)
                },
                actionTitle: "Adicionar candidatura",
                actionDescription: "Cadastre uma candidatura para\nacompanhar suas entrevistas",
                isNextInterview: isNextInterview
            )
        } else {
            EmptyInterviewListView(
                action: {
                    coordinator.auth.push(.login)
                },
                actionTitle: "Fazer login",
                actionDescription: "Faça o login para cadastrar\ne consultar entrevistas",
                isNextInterview: isNextInterview
            )
        }
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

extension Text {
    func textHomeStyle() -> Text {
        self
            .font(.title2)
            .bold()
    }
}
