//
//  DateInputField.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 13/01/25.
//

import SwiftUI

struct DateInputField: View {
    @Binding var dateString: String
    @State private var showDatePicker = false
    @State private var internalDate: Date = Date()
    let placeholder: String
    
    // NOVO: Adicione uma State para forçar atualização visual
    @State private var isDateStringValid: Bool = true // Assume válido inicialmente

    var body: some View {
        VStack {
            HStack {
                ZStack(alignment: .leading) {
                    if dateString.isEmpty {
                        Text(placeholder)
                            .foregroundColor(Color(.systemGray))
                            .padding(.leading, 12)
                    }
                    
                    TextField("", text: $dateString)
                        .onChange(of: dateString) { oldValue, newValue in
                            let formatted = formatInputDate(newValue)
                            dateString = formatted
                            
                            // Tenta atualizar internalDate se a string formatada for válida
                            if let date = DateFormatter.displayDateFormatter.date(from: dateString) {
                                internalDate = date
                            }
                            
                            // Atualiza a nova State para forçar reavaliação da cor
                            self.isDateStringValid = isValidDate(dateString) || dateString.isEmpty
                            
                            print("onChange - DateString: \(dateString), isValidDate: \(self.isDateStringValid)")
                        }
                        .keyboardType(.numbersAndPunctuation)
                        .padding(.leading, 12)
                        .padding(.vertical, 12)
                        // Use a nova State para a condição da cor
                        .foregroundColor(isDateStringValid ? .primary : .red)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.persianBlue, lineWidth: 1)
                )
                .padding(.trailing, 8)
                
                Button(action: { showDatePicker.toggle() }) {
                    Image(systemName: "calendar")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.persianBlue)
                }
            }
            
            if showDatePicker {
                DatePicker(
                    "",
                    selection: $internalDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .onChange(of: internalDate) {
                    dateString = DateFormatter.displayDateFormatter.string(from: internalDate)
                    showDatePicker = false
                    // Atualiza a validade após a seleção do picker também
                    self.isDateStringValid = isValidDate(dateString) || dateString.isEmpty
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.top, 5)
            }
        }
        .onAppear {
            if let date = DateFormatter.displayDateFormatter.date(from: dateString) {
                internalDate = date
            } else {
                internalDate = Date()
            }
        }
    }
    
    // MARK: - Date Formatting Logic
    private func formatInputDate(_ input: String) -> String {
        var cleanedString = input.filter { $0.isNumber }
        
        if cleanedString.count > 8 {
            cleanedString = String(cleanedString.prefix(8))
        }
        
        var formattedString = ""
        for (index, char) in cleanedString.enumerated() {
            formattedString.append(char)
            if index == 1 && cleanedString.count > 2 {
                formattedString.append("/")
            }
            if index == 3 && cleanedString.count > 4 {
                formattedString.append("/")
            }
        }
        
        if formattedString.count > 10 {
            formattedString = String(formattedString.prefix(10))
        }
        
        return formattedString
    }
    
    // MARK: - Helper Functions

    // Mantenha os prints para depuração temporariamente
    private func parseDate(from text: String) -> Date? {
        print("parseDate: Attempting to parse '\(text)'")
        let date = DateFormatter.displayDateFormatter.date(from: text)
        print("parseDate: Result for '\(text)' = \(date ?? "nil" as Any)")
        return date
    }
    
    private func isValidDate(_ text: String) -> Bool {
        let dateRegex = #"^\d{2}/\d{2}/\d{4}$"#
        let isFormatValid = text.range(of: dateRegex, options: .regularExpression) != nil
        
        print("isValidDate: Input text = '[\(text)]'")
        print("isValidDate: Regex check (isFormatValid) = \(isFormatValid)")
        
        let parsedDate = parseDate(from: text)
        print("isValidDate: Parsed Date (from parseDate) = \(parsedDate ?? "nil" as Any)")
        
        let result = text.isEmpty || (isFormatValid && parsedDate != nil)
        print("isValidDate: Final result = \(result)")
        
        return result
    }
}
struct DateInputField_Previews: PreviewProvider {
    static var previews: some View {
        DateInputField(dateString: .constant(""), placeholder: "Digite ou selecione a data")
    }
}
