//
//  GithubListing.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 18/07/25.
//

struct GitHubJobListing: Decodable, Identifiable {
    var id: String { url }
    let title: String
    let icon: String
    let url: String
    let published_at: String
    let updated_at: String
    let labels: [String]
    let repository: String
}
