//
//  ResumeFeedbackViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 27/06/25.
//

import Foundation
import SwiftUI

struct ResumeFeedbackSubmissionResponse: Codable {
    let task_id: String
}

final class ResumeFeedbackViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case polling
        case loaded
        case error
    }

    @Published var feedbackText: String?
    @Published var errorMessage: String?
    @Published private(set) var viewState: State = .idle

    private var task: Task<Void, Never>?
    private var pollingTimer: Timer?

    @MainActor
    func submitResumeFeedback(resumeURL: URL) {
        print("📡 Chamando /submit-feedback/")
        task?.cancel()
        viewState = .loading
        feedbackText = nil
        errorMessage = nil

        task = Task {
            do {
                let taskID = try await InterviewService.shared.submitFeedbackAndGetTaskID(resumeURL: resumeURL)
                viewState = .polling
                startPolling(for: taskID)
            } catch {
                errorMessage = error.localizedDescription
                viewState = .error
            }
        }
    }

    @MainActor
    private func startPolling(for taskID: String) {
        pollingTimer?.invalidate()

        pollingTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: true) { [weak self] timer in
            guard let self = self else { return }

            Task {
                do {
                    let isReady = try await InterviewService.shared.checkFeedbackStatus(taskID: taskID)
                    if isReady {
                        let feedback = try await InterviewService.shared.fetchFeedbackResult(taskID: taskID)
                        await MainActor.run {
                            self.feedbackText = feedback
                            self.viewState = .loaded
                            timer.invalidate()
                        }
                    }
                } catch {
                    await MainActor.run {
                        self.errorMessage = error.localizedDescription
                        self.viewState = .error
                        timer.invalidate()
                    }
                }
            }
        }
    }

    deinit {
        task?.cancel()
        pollingTimer?.invalidate()
    }
}


//final class ResumeFeedbackViewModel: ObservableObject {
//    enum State: Equatable {
//        case loading
//        case loaded
//        case error
//    }
//    
//    @Published var feedbackText: String?
//    @Published var isLoading = false
//    @Published var errorMessage: String?
//    @Published private(set) var viewState: State = .loaded
//
//    private var task: Task<Void, Never>?
//
//    @MainActor
//    func submitResumeFeedback(resumeURL: URL) {
//        task?.cancel()
//
//        task = Task {
//            self.viewState = .loading
//            self.feedbackText = nil
//            self.errorMessage = nil
//
//            do {
//                let feedback = try await InterviewService.shared.fetchResumeFeedback(resumeURL: resumeURL)
//                self.feedbackText = feedback
//                self.viewState = .loaded
//            } catch {
//                self.errorMessage = error.localizedDescription
//                self.viewState = .error
//            }
//        }
//    }
//
//    deinit {
//        task?.cancel()
//    }
//}
