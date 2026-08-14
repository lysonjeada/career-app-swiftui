//
//  TutorService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 12/08/26.
//

import Foundation

protocol TutorServiceProtocol {
    func fetchTutors(
        page: Int,
        pageSize: Int
    ) async throws -> TutorPageResponse

    func fetchTutor(
        id: String
    ) async throws -> Tutor
}


final class TutorService:
    TutorServiceProtocol {

    func fetchTutors(
        page: Int,
        pageSize: Int
    ) async throws -> TutorPageResponse {

        guard var components =
                URLComponents(
                    string:
                        "\(APIConstants.pythonURL)/tutors/"
                )
        else {
            throw URLError(.badURL)
        }

        components.queryItems = [
            URLQueryItem(
                name: "page",
                value: "\(page)"
            ),
            URLQueryItem(
                name: "page_size",
                value: "\(pageSize)"
            )
        ]

        guard let url =
                components.url
        else {
            throw URLError(.badURL)
        }

        var request =
            URLRequest(url: url)

        request.httpMethod = "GET"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        print(
            """
            👩‍🏫 GET Tutors:
            \(url.absoluteString)
            """
        )

        let (data, response) =
            try await URLSession.shared.data(
                for: request
            )

        guard let httpResponse =
                response as? HTTPURLResponse
        else {
            throw URLError(
                .badServerResponse
            )
        }

        guard
            200..<300 ~=
                httpResponse.statusCode
        else {
            throw URLError(
                .badServerResponse
            )
        }

        let decoder =
            JSONDecoder()

        decoder.keyDecodingStrategy =
            .convertFromSnakeCase

        return try decoder.decode(
            TutorPageResponse.self,
            from: data
        )
    }

    func fetchTutor(
        id: String
    ) async throws -> Tutor {

        guard let url = URL(
            string:
                "\(APIConstants.pythonURL)/tutors/\(id)"
        ) else {
            throw URLError(.badURL)
        }

        var request =
            URLRequest(url: url)

        request.httpMethod = "GET"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        let (data, response) =
            try await URLSession.shared.data(
                for: request
            )

        guard let httpResponse =
                response as? HTTPURLResponse,
              200..<300 ~=
                httpResponse.statusCode
        else {
            throw URLError(
                .badServerResponse
            )
        }

        let decoder =
            JSONDecoder()

        decoder.keyDecodingStrategy =
            .convertFromSnakeCase

        return try decoder.decode(
            Tutor.self,
            from: data
        )
    }
}
