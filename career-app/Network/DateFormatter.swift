//
//  DateFormatter.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 27/07/25.
//

import Foundation

// MARK: - Date Formatters

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

extension Date {
    func toDayMonthString() -> String {
        let formatter = DateFormatter()

        formatter.calendar = Calendar(
            identifier: .gregorian
        )

        formatter.locale = Locale(
            identifier: "en_US_POSIX"
        )

        /*
         IMPORTANTE:
         precisa ser o mesmo timezone usado
         quando "yyyy-MM-dd" foi convertido
         para Date.
         */
        formatter.timeZone = TimeZone(
            secondsFromGMT: 0
        )

        formatter.dateFormat = "dd/MM"

        let result = formatter.string(
            from: self
        )

        print(
            """
            📅 Date → dd/MM

            Date:
            \(self)

            Resultado:
            \(result)
            """
        )

        return result
    }
}
