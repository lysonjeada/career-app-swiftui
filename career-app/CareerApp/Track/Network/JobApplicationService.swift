//
//  JobApplicationService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 24/01/25.
//

// private let baseURL = APIConstants.baseURL

import Foundation

protocol JobApplicationServiceProtocol {
    func fetchInterviews() async throws -> [InterviewResponse]
    func fetchNextInterviews() async throws -> [InterviewResponse]
    func fetchJobListings(repository: String?) async throws -> [GitHubJobListing]
    func fetchAvailableRepositories() async throws -> [String]
    func addInterview(
        companyName: String,
        jobTitle: String,
        jobSeniority: String,
        lastInterview: String,
        nextInterview: String,
        location: String,
        notes: String,
        skills: [String]
    ) async throws
    func updateInterview(interviewId: String, request: InterviewRequest) async throws
    func deleteInterview(interviewId: String) async throws
}

class JobApplicationService: JobApplicationServiceProtocol {
    
    private func authorizedRequest(
        url: URL,
        method: String
    ) throws -> URLRequest {
        print(
            """
            🔎 AuthSession accessToken:
            \(AuthSession.shared.accessToken ?? "SEM TOKEN")
            """
        )

        guard let token =
            AuthSession.shared.accessToken,
              !token.isEmpty
        else {
            print(
                "❌ Não existe token na AuthSession"
            )

            throw URLError(
                .userAuthenticationRequired
            )
        }

        var request = URLRequest(url: url)

        request.httpMethod = method

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Content-Type"
        )

        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField:
                "Authorization"
        )

        return request
    }
    
    func fetchNextInterviews()
        async throws -> [InterviewResponse] {

        guard let url = URL(
            string:
                "\(APIConstants.pythonURL)/interviews/next/"
        ) else {
            throw APIError.invalidURL
        }

        var request = try authorizedRequest(
            url: url,
            method: "GET"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        let (data, response) =
            try await URLSession.shared.data(
                for: request
            )

        let processedData =
            try handleHTTPResponse(
                data: data,
                response: response
            )

        do {
            return try defaultJSONDecoder()
                .decode(
                    [InterviewResponse].self,
                    from: processedData
                )

        } catch {
            throw APIError.decodingError(
                error
            )
        }
    }
    
    func updateInterview(
        interviewId: String,
        request interviewRequest:
            InterviewRequest
    ) async throws {

        guard let url = URL(
            string:
                """
                \(APIConstants.pythonURL)/interviews/\(interviewId)
                """
        ) else {
            throw URLError(.badURL)
        }

        var request = try authorizedRequest(
            url: url,
            method: "PUT"
        )

        request.httpBody =
            try JSONEncoder().encode(
                interviewRequest
            )

        let (data, response) =
            try await URLSession.shared.data(
                for: request
            )

        guard let httpResponse =
                response as? HTTPURLResponse
        else {
            throw APIError.invalidResponse
        }

        print(
            """
            ✅ Código de resposta (PUT):
            \(httpResponse.statusCode)
            """
        )

        if let jsonString = String(
            data: data,
            encoding: .utf8
        ) {
            print(
                """
                📥 Resposta JSON (PUT):
                \(jsonString)
                """
            )
        }

        _ = try handleHTTPResponse(
            data: data,
            response: response
        )
    }
    
    func deleteInterview(
        interviewId: String
    ) async throws {

        guard let url = URL(
            string:
                """
                \(APIConstants.pythonURL)/interviews/\(interviewId)
                """
        ) else {
            throw URLError(.badURL)
        }

        let request = try authorizedRequest(
            url: url,
            method: "DELETE"
        )

        let (data, response) =
            try await URLSession.shared.data(
                for: request
            )

        guard let httpResponse =
                response as? HTTPURLResponse
        else {
            throw APIError.invalidResponse
        }

        print(
            """
            ✅ Código de resposta (DELETE):
            \(httpResponse.statusCode)
            """
        )

        guard
            200..<300 ~=
                httpResponse.statusCode
        else {
            _ = try handleHTTPResponse(
                data: data,
                response: response
            )

            return
        }
    }
    
    func addInterview(
        companyName: String,
        jobTitle: String,
        jobSeniority: String,
        lastInterview: String,
        nextInterview: String,
        location: String,
        notes: String = "",
        skills: [String]
    ) async throws {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd/MM/yyyy"
        inputFormatter.locale = Locale(
            identifier: "pt_BR"
        )

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd"
        outputFormatter.locale = Locale(
            identifier: "en_US_POSIX"
        )

        func formatDate(
            _ string: String
        ) -> String? {
            guard !string.isEmpty,
                  let date = inputFormatter.date(
                    from: string
                  )
            else {
                return nil
            }

            return outputFormatter.string(
                from: date
            )
        }

        // MARK: - Request body

        let requestBody = InterviewRequest(
            company_name: companyName,
            job_title: jobTitle,
            job_seniority: jobSeniority,
            last_interview_date:
                formatDate(lastInterview),
            next_interview_date:
                formatDate(nextInterview),
            location:
                location.isEmpty
                ? nil
                : location,
            notes:
                notes.isEmpty
                ? nil
                : notes,
            skills:
                skills.isEmpty
                ? nil
                : skills
        )

        // MARK: - URL

        guard let url = URL(
            string:
                "\(APIConstants.pythonURL)/interviews/"
        ) else {
            throw URLError(.badURL)
        }

        // MARK: - Encode body

        let requestData: Data

        do {
            requestData = try JSONEncoder().encode(
                requestBody
            )
        } catch {
            throw APIError.unknownError(
                error
            )
        }

        if let jsonString = String(
            data: requestData,
            encoding: .utf8
        ) {
            print(
                "📤 Corpo da requisição JSON:"
            )
            print(jsonString)
        }

        // MARK: - Authorized request

        var request = try authorizedRequest(
            url: url,
            method: "POST"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Content-Type"
        )

        request.httpBody = requestData

        // MARK: - Request

        let responseData: Data
        let response: URLResponse

        do {
            (
                responseData,
                response
            ) = try await URLSession.shared.data(
                for: request
            )
        } catch {
            throw APIError.unknownError(
                error
            )
        }

        // MARK: - Validate response

        guard let httpResponse =
                response as? HTTPURLResponse
        else {
            throw APIError.invalidResponse
        }

        print(
            """
            ✅ Código de resposta (POST): \(httpResponse.statusCode)
            """
        )

        // MARK: - Handle errors

        guard
            200..<300 ~= httpResponse.statusCode
        else {
            let errorMessage:
                String?

            if let jsonError =
                try? JSONSerialization
                    .jsonObject(
                        with: responseData
                    ) as? [String: Any] {

                if let detail =
                    jsonError["detail"]
                        as? String {

                    errorMessage = detail

                } else if let details =
                            jsonError["detail"]
                                as? [[String: Any]],
                          let firstDetail =
                            details.first,
                          let message =
                            firstDetail["msg"]
                                as? String {

                    errorMessage = message

                } else {
                    errorMessage = String(
                        data: responseData,
                        encoding: .utf8
                    )
                }

            } else {
                errorMessage = String(
                    data: responseData,
                    encoding: .utf8
                )
            }

            if (
                400..<500
            ).contains(
                httpResponse.statusCode
            ) {
                throw APIError.clientError(
                    statusCode:
                        httpResponse.statusCode,
                    message:
                        errorMessage
                )
            }

            if (
                500..<600
            ).contains(
                httpResponse.statusCode
            ) {
                throw APIError.serverError(
                    statusCode:
                        httpResponse.statusCode,
                    message:
                        errorMessage
                )
            }

            throw APIError.unknownError(
                URLError(
                    .badServerResponse
                )
            )
        }

        // MARK: - Success

        if let responseBody = String(
            data: responseData,
            encoding: .utf8
        ) {
            print(
                "📥 Resposta do servidor:"
            )

            print(responseBody)
        }
    }
}
// MARK: - JobApplicationService (Refatorado)

extension JobApplicationService {

    // MARK: - Private Helpers for JSON Handling

    private func defaultJSONEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        // Pydantic espera "yyyy-MM-dd" para date e ISO 8601 para datetime
        encoder.dateEncodingStrategy = .formatted(DateFormatter.iso8601BackendDateFormatter) // Se estiver enviando dates sem tempo
        // Se você estivesse enviando `datetime` em campos, poderia usar:
        // encoder.dateEncodingStrategy = .iso8601 // Ou .formatted(DateFormatter.iso8601BackendDateTimeFormatter)
        encoder.outputFormatting = .prettyPrinted // Para debug, remova em produção
        return encoder
    }

    private func defaultJSONDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        // Pydantic envia "yyyy-MM-dd" para date e ISO 8601 para datetime
        // Você precisa de uma estratégia de decodificação que lide com ambos.
        // O .iso8601 padrão do Swift é bom para a maioria dos casos.
        // Se suas datas de criação/atualização têm microsegundos e o Date(from:) falha,
        // use .formatted(DateFormatter.iso8601BackendDateTimeFormatter)
        decoder.dateDecodingStrategy = .custom { (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            if let date = DateFormatter.iso8601BackendDateFormatter.date(from: dateString) {
                return date
            } else if let dateTime = DateFormatter.iso8601BackendDateTimeFormatter.date(from: dateString) {
                return dateTime
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        return decoder
    }

    // MARK: - Common HTTP Response Handling

    private func handleHTTPResponse(data: Data, response: URLResponse) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        print("✅ Código de resposta: \(httpResponse.statusCode)")

        if !(200..<300).contains(httpResponse.statusCode) {
            let errorMessage: String?
            // Tenta decodificar a mensagem de erro do corpo da resposta
            if let jsonError = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                if let detailString = jsonError["detail"] as? String {
                    errorMessage = detailString
                } else if let detailArray = jsonError["detail"] as? [[String: Any]],
                          let firstDetail = detailArray.first,
                          let msg = firstDetail["msg"] as? String {
                    errorMessage = msg
                } else {
                    errorMessage = nil // Não foi possível extrair um detalhe específico
                }
            } else {
                errorMessage = String(data: data, encoding: .utf8) // Fallback para string bruta
            }

            if (400..<500).contains(httpResponse.statusCode) {
                throw APIError.clientError(statusCode: httpResponse.statusCode, message: errorMessage)
            } else if (500..<600).contains(httpResponse.statusCode) {
                throw APIError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
            } else {
                throw APIError.unknownError(URLError(.badServerResponse))
            }
        }

        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 Resposta JSON: \(jsonString)")
        }

        return data
    }

    // MARK: - API Methods

    func fetchInterviews()
        async throws -> [InterviewResponse] {

        guard let url = URL(
            string:
                "\(APIConstants.pythonURL)/interviews/"
        ) else {
            throw APIError.invalidURL
        }

        var request = try authorizedRequest(
            url: url,
            method: "GET"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        print(
            """
            🌐 GET Interviews:
            \(url.absoluteString)
            """
        )

        print(
            """
            🔐 Authorization:
            \(request.value(
                forHTTPHeaderField: "Authorization"
            ) ?? "SEM AUTHORIZATION")
            """
        )

        let (data, response) =
            try await URLSession.shared.data(
                for: request
            )

        let processedData =
            try handleHTTPResponse(
                data: data,
                response: response
            )

        do {
            return try defaultJSONDecoder()
                .decode(
                    [InterviewResponse].self,
                    from: processedData
                )

        } catch {
            throw APIError.decodingError(
                error
            )
        }
    }
}

extension JobApplicationService {
    func fetchJobListings(repository: String? = nil) async throws -> [GitHubJobListing] {
        var urlString = "\(APIConstants.pythonURL)/job-listings/"
        
        if let repository = repository, !repository.isEmpty {
            // Escapa caracteres especiais para URL (como /)
            if let encodedRepo = repository.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                urlString += "?repository=\(encodedRepo)"
            }
        }
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("✅ Código de resposta (GET Job Listings): \(httpResponse.statusCode)")
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 Resposta JSON Job Listings:")
            print(jsonString)
        }
        
        return try JSONDecoder().decode([GitHubJobListing].self, from: data)
    }
}


extension JobApplicationService {
    func fetchAvailableRepositories() async throws -> [String] {
        guard let url = URL(string: "\(APIConstants.pythonURL)/repositories-available/") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("✅ Código de resposta (GET Repositories): \(httpResponse.statusCode)")
        }

        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 Repositórios disponíveis:")
            print(jsonString)
        }

        return try JSONDecoder().decode([String].self, from: data)
    }
}
