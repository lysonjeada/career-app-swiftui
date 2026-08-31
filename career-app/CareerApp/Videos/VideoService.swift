//
//  VideoService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 14/08/26.
//

import Foundation

protocol VideoServiceProtocol {
    func fetchMyVideos(
        page: Int,
        pageSize: Int
    ) async throws
        -> VideoPageResponse

    func fetchApprovedVideos(
        page: Int,
        pageSize: Int
    ) async throws
        -> VideoPageResponse

    func fetchVideo(
        id: String
    ) async throws
        -> TechVideo

    func uploadVideo(
        title: String,
        description: String,
        fileURL: URL,
        autoThumbnailData: Data?,
        customThumbnailData: Data?
    ) async throws
        -> TechVideo

    func deleteVideo(
        id: String
    ) async throws

    func resendReviewNotification(
        id: String
    ) async throws -> TechVideo

    /// Envia uma nova imagem para a thumbnail — fica pendente de
    /// aprovação por e-mail; a thumbnail exibida (`thumbnailUrl`)
    /// continua sendo a anterior até a decisão.
    func updateThumbnail(
        id: String,
        imageData: Data
    ) async throws -> TechVideo

    func resendThumbnailReviewNotification(
        id: String
    ) async throws -> TechVideo

    /// Define a reação do usuário atual (like ou dislike) —
    /// substitui uma reação anterior, já que só é permitida 1 por
    /// usuário por vídeo.
    func setReaction(
        videoId: String,
        reaction: VideoReactionType
    ) async throws -> TechVideo

    /// Remove a reação do usuário atual, se houver.
    func removeReaction(
        videoId: String
    ) async throws -> TechVideo

    func addFavorite(
        videoId: String
    ) async throws -> TechVideo

    func removeFavorite(
        videoId: String
    ) async throws -> TechVideo

    func fetchFavoriteVideos(
        page: Int,
        pageSize: Int
    ) async throws -> VideoPageResponse
}


final class VideoService:
    VideoServiceProtocol {

    private let decoder:
        JSONDecoder = {

        let decoder =
            JSONDecoder()

        decoder.keyDecodingStrategy =
            .convertFromSnakeCase

        return decoder
    }()
    
    func uploadVideo(
        title: String,
        description: String,
        fileURL: URL,
        autoThumbnailData: Data? = nil,
        customThumbnailData: Data? = nil
    ) async throws -> TechVideo {
        guard let url = URL(
            string:
                "\(APIConstants.pythonURL)/videos/"
        ) else {
            throw URLError(.badURL)
        }

        print(
            """
            🎬 Preparando upload do vídeo

            Título:
            \(title)

            Arquivo:
            \(fileURL.lastPathComponent)
            """
        )

        let multipart =
            try MultipartFileBuilder.build(
                title: title,
                description: description,
                videoURL: fileURL,
                autoThumbnailData: autoThumbnailData,
                customThumbnailData: customThumbnailData
            )

        defer {
            do {
                try FileManager.default
                    .removeItem(
                        at: multipart.fileURL
                    )

                print(
                    "🧹 Multipart temporário removido"
                )

            } catch {
                print(
                    """
                    ⚠️ Não foi possível remover
                    o arquivo multipart temporário:

                    \(error)
                    """
                )
            }
        }

        var request =
            URLRequest(url: url)

        request.httpMethod =
            "POST"

        request.timeoutInterval =
            300

        request.setValue(
            """
            multipart/form-data; boundary=\(multipart.boundary)
            """,
            forHTTPHeaderField:
                "Content-Type"
        )

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Accept"
        )

        print(
            """
            🚀 Iniciando upload

            URL:
            \(url.absoluteString)

            Refresh disponível:
            \(AuthSession.shared.refreshToken != nil)
            """
        )

        let responseData: Data
        let response: URLResponse

        do {
            (
                responseData,
                response
            ) = try await AuthenticatedHTTPClient
                .shared
                .upload(
                    for: request,
                    fromFile:
                        multipart.fileURL
                )

        } catch {
            print(
                """
                ❌ Erro durante upload do vídeo:

                \(error)
                """
            )

            throw error
        }

        guard let httpResponse =
                response as? HTTPURLResponse
        else {
            throw URLError(
                .badServerResponse
            )
        }

        print(
            """
            📥 Status upload:
            \(httpResponse.statusCode)
            """
        )

        if let rawResponse = String(
            data: responseData,
            encoding: .utf8
        ) {
            print(
                """
                📦 Resposta upload:

                \(rawResponse)
                """
            )
        }

        // MARK: - Unauthorized

        if httpResponse.statusCode == 401 {
            throw URLError(
                .userAuthenticationRequired
            )
        }

        // MARK: - Backend Error

        guard
            200..<300 ~=
                httpResponse.statusCode
        else {
            let errorMessage =
                Self.extractVideoError(
                    from: responseData
                )

            throw VideoServiceError
                .serverError(
                    statusCode:
                        httpResponse.statusCode,
                    message:
                        errorMessage
                )
        }

        // MARK: - Decode

        do {
            let decoder =
                JSONDecoder()

            decoder.keyDecodingStrategy =
                .convertFromSnakeCase

            let video =
                try decoder.decode(
                    TechVideo.self,
                    from: responseData
                )

            print(
                """
                ✅ Vídeo enviado com sucesso

                ID:
                \(video.id)

                Status:
                \(video.status.rawValue)
                """
            )

            return video

        } catch {
            print(
                """
                ❌ Erro ao decodificar
                resposta do upload:

                \(error)
                """
            )

            throw VideoServiceError
                .decodingError(
                    error
                )
        }
    }

    func fetchMyVideos(
        page: Int,
        pageSize: Int
    ) async throws
        -> VideoPageResponse {

        guard let url = URL(
            string:
                """
                \(APIConstants.pythonURL)/videos/mine?page=\(page)&page_size=\(pageSize)
                """
        ) else {
            throw URLError(.badURL)
        }

        var request =
            try authorizedRequest(
                url: url,
                method: "GET"
            )

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Accept"
        )

        let (data, response) =
            try await AuthenticatedHTTPClient.shared
                .data(
                    for: request
                )

        try validate(
            response
        )

        return try decoder.decode(
            VideoPageResponse.self,
            from: data
        )
    }


    func fetchApprovedVideos(
        page: Int,
        pageSize: Int
    ) async throws
        -> VideoPageResponse {

        guard let url = URL(
            string:
                """
                \(APIConstants.pythonURL)/videos/approved?page=\(page)&page_size=\(pageSize)
                """
        ) else {
            throw URLError(.badURL)
        }

        let (
            data,
            response
        ) = try await URLSession.shared
            .data(
                from: url
            )

        try validate(
            response
        )

        return try decoder.decode(
            VideoPageResponse.self,
            from: data
        )
    }


    func fetchVideo(
        id: String
    ) async throws
        -> TechVideo {

        guard let url = URL(
            string:
                "\(APIConstants.pythonURL)/videos/\(id)"
        ) else {
            throw URLError(.badURL)
        }

        let request =
            try authorizedRequest(
                url: url,
                method: "GET"
            )

        let (data, response) =
            try await AuthenticatedHTTPClient.shared
                .data(
                    for: request
                )

        try validate(
            response
        )

        return try decoder.decode(
            TechVideo.self,
            from: data
        )
    }


    func deleteVideo(
        id: String
    ) async throws {

        guard let url = URL(
            string:
                "\(APIConstants.pythonURL)/videos/\(id)"
        ) else {
            throw URLError(.badURL)
        }

        let request =
            try authorizedRequest(
                url: url,
                method: "DELETE"
            )

        let (_, response) =
            try await AuthenticatedHTTPClient.shared
                .data(
                    for: request
                )

        try validate(
            response
        )
    }


    func resendReviewNotification(
        id: String
    ) async throws -> TechVideo {

        guard let url = URL(
            string:
                "\(APIConstants.pythonURL)/videos/\(id)/resend-review"
        ) else {
            throw URLError(.badURL)
        }

        var request =
            try authorizedRequest(
                url: url,
                method: "POST"
            )

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Accept"
        )

        let (data, response) =
            try await AuthenticatedHTTPClient.shared
                .data(
                    for: request
                )

        guard let httpResponse =
                response as? HTTPURLResponse
        else {
            throw VideoServiceError
                .invalidResponse
        }

        guard
            200..<300 ~=
                httpResponse.statusCode
        else {
            throw VideoServiceError
                .serverError(
                    statusCode:
                        httpResponse.statusCode,
                    message:
                        Self.extractVideoError(
                            from: data
                        )
                )
        }

        return try decoder.decode(
            ResendReviewResponse.self,
            from: data
        ).video
    }


    func updateThumbnail(
        id: String,
        imageData: Data
    ) async throws -> TechVideo {

        guard let url = URL(
            string:
                "\(APIConstants.pythonURL)/videos/\(id)/thumbnail"
        ) else {
            throw URLError(.badURL)
        }

        let multipart = MultipartFileBuilder.buildSinglePart(
            name: "thumbnail",
            fileName: "thumbnail.jpg",
            contentType: "image/jpeg",
            data: imageData
        )

        var request = URLRequest(url: url)

        request.httpMethod = "PUT"

        request.setValue(
            """
            multipart/form-data; boundary=\(multipart.boundary)
            """,
            forHTTPHeaderField:
                "Content-Type"
        )

        request.httpBody = multipart.body

        // Via AuthenticatedHTTPClient (não authorizedRequest +
        // URLSession direto) para reaproveitar o refresh automático
        // de token em caso de 401, igual ao uploadVideo.
        let (data, response) =
            try await AuthenticatedHTTPClient
                .shared
                .data(for: request)

        guard let httpResponse =
                response as? HTTPURLResponse
        else {
            throw VideoServiceError
                .invalidResponse
        }

        guard
            200..<300 ~=
                httpResponse.statusCode
        else {
            throw VideoServiceError
                .serverError(
                    statusCode:
                        httpResponse.statusCode,
                    message:
                        Self.extractVideoError(
                            from: data
                        )
                )
        }

        return try decoder.decode(
            TechVideo.self,
            from: data
        )
    }


    func resendThumbnailReviewNotification(
        id: String
    ) async throws -> TechVideo {

        guard let url = URL(
            string:
                "\(APIConstants.pythonURL)/videos/\(id)/resend-thumbnail-review"
        ) else {
            throw URLError(.badURL)
        }

        var request =
            try authorizedRequest(
                url: url,
                method: "POST"
            )

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Accept"
        )

        let (data, response) =
            try await AuthenticatedHTTPClient.shared
                .data(
                    for: request
                )

        guard let httpResponse =
                response as? HTTPURLResponse
        else {
            throw VideoServiceError
                .invalidResponse
        }

        guard
            200..<300 ~=
                httpResponse.statusCode
        else {
            throw VideoServiceError
                .serverError(
                    statusCode:
                        httpResponse.statusCode,
                    message:
                        Self.extractVideoError(
                            from: data
                        )
                )
        }

        return try decoder.decode(
            ResendThumbnailReviewResponse.self,
            from: data
        ).video
    }


    func setReaction(
        videoId: String,
        reaction: VideoReactionType
    ) async throws -> TechVideo {

        guard let url = URL(
            string:
                "\(APIConstants.pythonURL)/videos/\(videoId)/reaction"
        ) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        request.httpBody = try JSONEncoder().encode(
            ["reaction": reaction.rawValue]
        )

        return try await sendAuthenticatedVideoRequest(
            request
        )
    }

    func removeReaction(
        videoId: String
    ) async throws -> TechVideo {

        guard let url = URL(
            string:
                "\(APIConstants.pythonURL)/videos/\(videoId)/reaction"
        ) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        return try await sendAuthenticatedVideoRequest(
            request
        )
    }

    func addFavorite(
        videoId: String
    ) async throws -> TechVideo {

        guard let url = URL(
            string:
                "\(APIConstants.pythonURL)/videos/\(videoId)/favorite"
        ) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        return try await sendAuthenticatedVideoRequest(
            request
        )
    }

    func removeFavorite(
        videoId: String
    ) async throws -> TechVideo {

        guard let url = URL(
            string:
                "\(APIConstants.pythonURL)/videos/\(videoId)/favorite"
        ) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        return try await sendAuthenticatedVideoRequest(
            request
        )
    }

    func fetchFavoriteVideos(
        page: Int,
        pageSize: Int
    ) async throws -> VideoPageResponse {

        guard let url = URL(
            string:
                """
                \(APIConstants.pythonURL)/videos/favorites?page=\(page)&page_size=\(pageSize)
                """
        ) else {
            throw URLError(.badURL)
        }

        var request =
            try authorizedRequest(
                url: url,
                method: "GET"
            )

        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Accept"
        )

        let (data, response) =
            try await AuthenticatedHTTPClient.shared
                .data(
                    for: request
                )

        try validate(
            response
        )

        return try decoder.decode(
            VideoPageResponse.self,
            from: data
        )
    }

    /// Helper comum a reação/favorito: todos são POST/DELETE simples
    /// sem corpo relevante na resposta além do TechVideo atualizado,
    /// via AuthenticatedHTTPClient (renova o token automaticamente
    /// em caso de 401, ao contrário de authorizedRequest +
    /// URLSession direto).
    private func sendAuthenticatedVideoRequest(
        _ request: URLRequest
    ) async throws -> TechVideo {
        let (data, response) =
            try await AuthenticatedHTTPClient
                .shared
                .data(for: request)

        guard let httpResponse =
                response as? HTTPURLResponse
        else {
            throw VideoServiceError
                .invalidResponse
        }

        guard
            200..<300 ~=
                httpResponse.statusCode
        else {
            throw VideoServiceError
                .serverError(
                    statusCode:
                        httpResponse.statusCode,
                    message:
                        Self.extractVideoError(
                            from: data
                        )
                )
        }

        return try decoder.decode(
            TechVideo.self,
            from: data
        )
    }


    private func authorizedRequest(
        url: URL,
        method: String
    ) throws -> URLRequest {

        guard let token =
                AuthSession.shared
                    .accessToken
        else {
            throw URLError(
                .userAuthenticationRequired
            )
        }

        var request =
            URLRequest(url: url)

        request.httpMethod =
            method

        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField:
                "Authorization"
        )

        return request
    }


    private func validate(
        _ response: URLResponse
    ) throws {
        guard let httpResponse =
                response as? HTTPURLResponse,
              200..<300 ~=
                httpResponse.statusCode
        else {
            throw URLError(
                .badServerResponse
            )
        }
    }
    
    private static func extractVideoError(
        from data: Data
    ) -> String? {
        guard !data.isEmpty else {
            return nil
        }

        if let json =
            try? JSONSerialization
                .jsonObject(
                    with: data
                ) as? [String: Any] {

            if let detail =
                json["detail"]
                    as? String {

                return detail
            }

            if let details =
                json["detail"]
                    as? [[String: Any]],
               let first =
                details.first,
               let message =
                first["msg"]
                    as? String {

                return message
            }

            if let detail =
                json["detail"]
                    as? [String: Any],
               let message =
                detail["message"]
                    as? String {

                return message
            }
        }

        return String(
            data: data,
            encoding: .utf8
        )
    }
}

private struct ResendReviewResponse: Decodable {
    let video: TechVideo
    let nextResendAllowedAt: String
}

private struct ResendThumbnailReviewResponse: Decodable {
    let video: TechVideo
    let nextResendAllowedAt: String
}

enum VideoServiceError:
    LocalizedError {

    case invalidURL
    case invalidResponse

    case serverError(
        statusCode: Int,
        message: String?
    )

    case decodingError(
        Error
    )

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return """
            A URL do serviço de vídeos
            é inválida.
            """

        case .invalidResponse:
            return """
            O servidor retornou
            uma resposta inválida.
            """

        case let .serverError(
            statusCode,
            message
        ):
            if let message,
               !message.isEmpty {
                return message
            }

            return """
            Não foi possível enviar o vídeo.
            Erro \(statusCode).
            """

        case let .decodingError(
            error
        ):
            return """
            Não foi possível interpretar
            a resposta do servidor:

            \(error.localizedDescription)
            """
        }
    }
}
