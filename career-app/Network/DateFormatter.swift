//
//  DateFormatter.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 27/07/25.
//

import Foundation

// MARK: - Date Formatters
extension Date {
    /// Converte um objeto `Date` para uma string no formato "DD/MM".
    /// - Returns: A data formatada como "DD/MM".
    func toDayMonthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        formatter.locale = Locale(identifier: "pt_BR") // Para garantir o formato BR (dia/mês)
        formatter.calendar = Calendar(identifier: .gregorian) // Consistência do calendário
        return formatter.string(from: self)
    }
}

extension DateFormatter {
    // Para exibir no TextField (formato BR) - usado apenas no DateInputField
    static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.calendar = Calendar(identifier: .gregorian) // Garante consistência
        return formatter
    }()

    // Para comunicação com o backend (formato ISO 8601 YYYY-MM-DD para 'date' do Python)
    static let iso8601BackendDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX") // Importante para ISO 8601 consistente
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // GMT para consistência
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()

    // Para comunicação com o backend (formato ISO 8601 com tempo para 'datetime' do Python)
    static let iso8601BackendDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS" // Ex: 2023-10-27T10:30:00.123456
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }()
}
