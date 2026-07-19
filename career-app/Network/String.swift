//
//  String.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 28/07/25.
//

import Foundation
import SwiftUI // Necessário para Text e Font, caso você queira usar em SwiftUI

extension String {
    /// Converte uma string de texto com formatação Markdown básica (negrito com **)
    /// e listas numeradas (1., 2., etc.) para um NSAttributedString,
    /// aplicando negrito onde necessário.
    ///
    /// - Returns: Um NSAttributedString formatado.
    func formattedFeedbackText() -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        let fullRange = NSRange(location: 0, length: attributedString.length)

        // MARK: - 1. Formatar texto entre ** ** para negrito
        do {
            let regex = try NSRegularExpression(pattern: "\\*\\*(.*?)\\*\\*", options: [])
            let matches = regex.matches(in: self, options: [], range: fullRange)

            // Percorre as correspondências em ordem inversa para evitar problemas com mudanças de range
            for match in matches.reversed() {
                let boldRange = match.range(at: 1) // Captura o grupo dentro dos asteriscos
                let fullMatchRange = match.range(at: 0) // Captura a correspondência completa (incluindo **)

                // Aplica a fonte negrito
                attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 17), range: boldRange) // Ajuste o tamanho da fonte conforme necessário

                // Remove os asteriscos (**)
                attributedString.replaceCharacters(in: NSRange(location: fullMatchRange.location + fullMatchRange.length - 2, length: 2), with: "") // Remove o segundo **
                attributedString.replaceCharacters(in: NSRange(location: fullMatchRange.location, length: 2), with: "") // Remove o primeiro **
            }
        } catch {
            print("Erro na regex de negrito: \(error)")
        }

        // MARK: - 2. Formatar números de lista (1., 2., etc.) para negrito
        do {
            // Regex para capturar "Número." no início da linha, ou após um espaço/nova linha
            let regex = try NSRegularExpression(pattern: "(^|\\n)(\\d+\\.)", options: [])
            let matches = regex.matches(in: attributedString.string, options: [], range: fullRange)

            for match in matches.reversed() {
                let numberRange = match.range(at: 2) // Captura o grupo do número e o ponto (ex: "1.")

                // Aplica a fonte negrito ao número da lista
                attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 17), range: numberRange) // Ajuste o tamanho da fonte
            }
        } catch {
            print("Erro na regex de lista: \(error)")
        }

        return attributedString
    }
}

extension String {
    /// Converte uma string no formato "yyyy-MM-dd" para um `Date`.
    func toDate(format: String = "yyyy-MM-dd") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX") // evita problemas com localizações
        formatter.timeZone = TimeZone(secondsFromGMT: 0)     // ajusta para UTC se necessário
        return formatter.date(from: self)
    }
}
