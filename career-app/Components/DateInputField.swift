//
//  DateInputField.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 13/01/25.
//

import SwiftUI

struct DateInputField: View {
    @State private var date: Date = Date()
    @State private var showDatePicker = false
    @State private var dateString: String = ""
    let placeholder: String
    
    var body: some View {
        VStack {
            HStack {
                ZStack(alignment: .leading) {
                    Text(placeholder)
                        .foregroundColor(Color.persianBlue.opacity(0.5))
                        .padding(.leading)
                    
                    TextField("", text: $dateString)
                        .onChange(of: dateString) { newValue in
                            validateAndUpdateDate(from: newValue)
                        }
                        .keyboardType(.numbersAndPunctuation)
                        .padding(.vertical, 12)
                        .foregroundColor(isValidDate(dateString) ? .persianBlue : .red)
                        .foregroundColor(.persianBlue) // Cor do texto digitado
                }
                
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.persianBlue, lineWidth: 1)
                )
                .padding(.trailing, 8)
                Button(action: {
                    showDatePicker.toggle()
                }) {
                    Image(systemName: "calendar")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.persianBlue)
                }
            }
            
            if showDatePicker {
                DatePicker(
                    "",
                    selection: $date,
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .onChange(of: date) { newDate in
                    dateString = formatDate(newDate)
                }
                .frame(maxWidth: .infinity, maxHeight: 300)
                .background(Color.white)
                .cornerRadius(12)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }
    
    private func validateAndUpdateDate(from text: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        if let parsedDate = formatter.date(from: text) {
            date = parsedDate
        }
    }
    
    private func isValidDate(_ text: String) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.date(from: text) != nil
    }
}

struct DateInputField_Previews: PreviewProvider {
    static var previews: some View {
        DateInputField(placeholder: "Digite ou selecione a data")
    }
}
