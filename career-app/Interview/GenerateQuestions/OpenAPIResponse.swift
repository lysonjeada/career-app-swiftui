//
//  OpenAPIResponse.swift
//  career-app
//
//  Created by Amaryllis Rosemaria Baldrez Calefi on 23/10/24.
//

import Foundation

struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let content: String
}
