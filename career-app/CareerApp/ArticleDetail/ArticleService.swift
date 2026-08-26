//
//  ArticleService.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 06/03/25.
//

import Foundation

protocol ArticleServiceProtocol {
    func fetchArticle(id: Int) async throws -> ArticleDetail

    func addFavorite(articleId: Int) async throws -> Bool
    func removeFavorite(articleId: Int) async throws -> Bool
    func fetchFavoriteArticles() async throws -> [ArticleDetail]
}

final class ArticleService: ArticleServiceProtocol {
    func fetchArticle(id: Int) async throws -> ArticleDetail {
        print("🟢 Iniciando fetchArticle para o ID: \(id)")

        // O app nunca fala direto com o dev.to — o backend intermedia
        // essa busca e anota `is_favorited` quando o usuário está
        // logado.
        guard let url = URL(string: "\(APIConstants.pythonURL)/articles/\(id)") else {
            print("🔴 Erro: URL inválida para o ID \(id)")
            throw URLError(.badURL)
        }
        print("🟡 URL construída: \(url.absoluteString)")

        let request = URLRequest(url: url)

        // 2. Chamada à API
        do {
            print("🟡 Fazendo requisição...")

            // A rota é pública/opcional no backend (convidado também
            // vê o artigo), mas quando HÁ sessão precisa passar pelo
            // AuthenticatedHTTPClient — ele renova o token se estiver
            // expirado. Ler `AuthSession.shared.accessToken` direto
            // (como antes) mandava um token vencido sem renovar; o
            // backend então tratava a requisição como se fosse de um
            // convidado e devolvia `is_favorited: false` mesmo
            // quando o artigo já tinha sido favoritado — sem erro
            // nenhum aparecer, o que tornava impossível desfazer o
            // favorito pela tela de detalhe.
            let (data, response) =
                AuthSession.shared.isAuthenticated
                ? try await AuthenticatedHTTPClient.shared.data(for: request)
                : try await URLSession.shared.data(for: request)
            
            // 3. Verificação do status HTTP (opcional)
            if let httpResponse = response as? HTTPURLResponse {
                print("🟡 Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("🔴 Erro: Status HTTP inesperado (\(httpResponse.statusCode))")
                }
            }
            
            // 4. Log dos dados brutos (útil para debug)
            let rawDataString = String(data: data, encoding: .utf8)
            print("🟡 Dados brutos recebidos: \(rawDataString ?? "vazio/não decodificável")")
            
            // 5. Decodificação
            //
            // ArticleDetail já declara CodingKeys explícitos em
            // snake_case (ex.: `case isFavorited = "is_favorited"`).
            // Somar `.convertFromSnakeCase` aqui faz o decoder converter
            // a chave do JSON ("is_favorited" -> "isFavorited") e depois
            // tentar casar com o `stringValue` do CodingKey, que é
            // literalmente "is_favorited" — nunca bate. Pra todo campo
            // Optional com CodingKey explícito isso falha em silêncio e
            // vira nil (era a causa real da estrela de favorito voltar
            // desmarcada: `article.isFavorited` chegava sempre nil, e
            // `?? false` escondia o problema).
            let decoder = JSONDecoder()
            let fetchedArticle = try decoder.decode(ArticleDetail.self, from: data)
            print("🟢 Artigo decodificado com sucesso: \(fetchedArticle)")
            return fetchedArticle
            
        } catch {
            print("🔴 Erro durante a requisição ou decodificação: \(error.localizedDescription)")
            if let decodingError = error as? DecodingError {
                print("Detalhes do erro:", decodingError.localizedDescription)
            }
            throw error // Re-lança o erro para o caller
        }
    }

    func addFavorite(articleId: Int) async throws -> Bool {
        try await sendFavoriteRequest(
            articleId: articleId,
            method: "POST"
        )
    }

    func removeFavorite(articleId: Int) async throws -> Bool {
        try await sendFavoriteRequest(
            articleId: articleId,
            method: "DELETE"
        )
    }

    private func sendFavoriteRequest(
        articleId: Int,
        method: String
    ) async throws -> Bool {
        guard let url = URL(
            string:
                "\(APIConstants.pythonURL)/articles/\(articleId)/favorite"
        ) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        let (data, response) =
            try await AuthenticatedHTTPClient.shared.data(
                for: request
            )

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode
        else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(
            FavoriteToggleResponse.self,
            from: data
        )

        return decoded.isFavorited
    }

    func fetchFavoriteArticles() async throws -> [ArticleDetail] {
        guard let url = URL(
            string: "\(APIConstants.pythonURL)/articles/favorites"
        ) else {
            throw URLError(.badURL)
        }

        let request = URLRequest(url: url)

        let (data, response) =
            try await AuthenticatedHTTPClient.shared.data(
                for: request
            )

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode
        else {
            throw URLError(.badServerResponse)
        }

        // Sem .convertFromSnakeCase — ArticleDetail já tem CodingKeys
        // explícitos em snake_case (ver fetchArticle acima).
        let decoder = JSONDecoder()

        return try decoder.decode(
            ArticleFavoritesResponse.self,
            from: data
        ).items
    }
}

private struct FavoriteToggleResponse: Decodable {
    let isFavorited: Bool

    enum CodingKeys: String, CodingKey {
        case isFavorited = "is_favorited"
    }
}

private struct ArticleFavoritesResponse: Decodable {
    let items: [ArticleDetail]
}
