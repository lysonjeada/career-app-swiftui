//
//  Question.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 18/06/25.
//

import Foundation

struct Question: Decodable, Identifiable {
    let id: String
    let question: String
}
