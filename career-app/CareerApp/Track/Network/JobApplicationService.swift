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
    
    func fetchNextInterviews() async throws -> [InterviewResponse] {
        guard let url = URL(string: "\(APIConstants.pythonURL)/interviews/next/") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        let processedData = try handleHTTPResponse(data: data, response: response)

        do {
            // Usa o decoder padronizado para lidar com datas
            return try defaultJSONDecoder().decode([InterviewResponse].self, from: processedData)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    func updateInterview(interviewId: String, request: InterviewRequest) async throws {
        guard let url = URL(string: "\(APIConstants.pythonURL)/interviews/\(interviewId)") else {
            throw URLError(.badURL)
        }
        
        var requestData = URLRequest(url: url)
        requestData.httpMethod = "PUT"
        requestData.setValue("application/json", forHTTPHeaderField: "Content-Type")
        requestData.httpBody = try JSONEncoder().encode(request)
        
        let (data, response) = try await URLSession.shared.data(for: requestData)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("✅ Código de resposta (PUT): \(httpResponse.statusCode)")
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📤 Resposta JSON (PUT):")
            print(jsonString)
        }
    }
    
    func deleteInterview(interviewId: String) async throws {
        guard let url = URL(string: "\(APIConstants.pythonURL)/interviews/\(interviewId)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            print("\u{2705} Código de resposta (DELETE): \(httpResponse.statusCode)")
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

            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM-dd"

            func formatDate(_ string: String) -> String? {
                guard let date = inputFormatter.date(from: string) else { return nil }
                return outputFormatter.string(from: date)
            }

            // Cuidado com skills: se seu backend espera `nil` para array vazio
            // você pode precisar usar `skills.isEmpty ? nil : skills`
            // Mas se espera um array vazio `[]` para "sem skills", use `skills` direto.
            // Verifique o schema Python `InterviewRequest`.
            let requestBody = InterviewRequest(
                company_name: companyName,
                job_title: jobTitle,
                job_seniority: jobSeniority,
                last_interview_date: formatDate(lastInterview),
                next_interview_date: formatDate(nextInterview),
                location: location.isEmpty ? nil : location,
                notes: notes.isEmpty ? nil : notes,
                skills: skills.isEmpty ? nil : skills // Ajuste aqui se seu backend aceita [] para "sem skills"
            )

            guard let url = URL(string: "\(APIConstants.pythonURL)/interviews/") else {
                throw URLError(.badURL)
            }

            let data: Data
            do {
                data = try JSONEncoder().encode(requestBody)
            } catch {
                throw APIError.unknownError(error) // Erro na codificação do JSON
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("📤 Corpo da requisição JSON:")
                print(jsonString)
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data

            let (responseData, response) = try await URLSession.shared.data(for: request)

            // Verificação do status code (MESMA LÓGICA DO updateInterview)
            if let httpResponse = response as? HTTPURLResponse {
                print("✅ Código de resposta (POST): \(httpResponse.statusCode)")

                if !(200..<300).contains(httpResponse.statusCode) { // Verifica se não é um status de sucesso (2xx)
                    let errorMessage: String?
                    // Tenta decodificar uma mensagem de erro do corpo da resposta, se disponível
                    // A estrutura de erro do FastAPI geralmente é {"detail": "mensagem"} ou {"detail": [{"loc": ..., "msg": ...}]}
                    if let jsonError = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
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
                        errorMessage = String(data: responseData, encoding: .utf8) // Fallback para string bruta
                    }

                    if (400..<500).contains(httpResponse.statusCode) {
                        throw APIError.clientError(statusCode: httpResponse.statusCode, message: errorMessage)
                    } else if (500..<600).contains(httpResponse.statusCode) {
                        throw APIError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
                    } else {
                        // Para outros códigos de erro não previstos nas faixas 4xx/5xx mas que não são 2xx
                        throw APIError.unknownError(URLError(.badServerResponse))
                    }
                }
            } else {
                throw APIError.invalidResponse // Se a resposta não for HTTPURLResponse
            }

            // Se chegou até aqui, a resposta é 2xx (sucesso)
            if let responseBody = String(data: responseData, encoding: .utf8) {
                print("📥 Resposta do servidor:")
                print(responseBody)
            }
            // Se você espera um retorno específico do servidor (ex: o objeto criado),
            // você deveria decodificar 'responseData' aqui:
            // let newInterview = try JSONDecoder().decode(InterviewOut.self, from: responseData)
            // return newInterview
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

    func fetchInterviews() async throws -> [InterviewResponse] {
        guard let url = URL(string: "\(APIConstants.pythonURL)/interviews/") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        let processedData = try handleHTTPResponse(data: data, response: response)

        do {
            // Usa o decoder padronizado para lidar com datas
            return try defaultJSONDecoder().decode([InterviewResponse].self, from: processedData)
        } catch {
            throw APIError.decodingError(error)
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
