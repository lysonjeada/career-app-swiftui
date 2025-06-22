//
//  TechStepAPI.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 18/06/25.
//

import Foundation

enum TechStepAPI {
    case listAllQuestions
    case saveQuestions
    case listSavedQuestions
    case listAllAppliedJobs
    case listAllNextInterviews
}

extension TechStepAPI {
    var baseURL: String {
        APIConstants.baseURL
    }

    var path: String {
        switch self {
        case .listAllQuestions:
            return "/questions"
        case .saveQuestions:
            return "/questions/save"
        case .listSavedQuestions:
            return "/questions/saved"
        case .listAllAppliedJobs:
            return "/jobs/applied"
        case .listAllNextInterviews:
            return "/jobs/next-interviews"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .listAllQuestions,
             .saveQuestions,
             .listSavedQuestions:
            return .post
        case .listAllAppliedJobs,
             .listAllNextInterviews:
            return .get
        }
    }

    var body: Data? {
        switch self {
        case .saveQuestions:
            // Se no futuro precisar de body, adicione aqui
            return nil
        default:
            return nil
        }
    }

    var urlRequest: URLRequest {
        let url = URL(string: baseURL + path)!
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        return request
    }
}
