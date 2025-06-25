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
                        .onChange(of: dateString, perform: validateAndUpdateDate)
                        .keyboardType(.numbersAndPunctuation)
                        .padding(.leading, 12)
                        .padding(.vertical, 12)
                        .foregroundColor(isValidDate(dateString) ? .primary : .red)
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
                DatePicker("", selection: $internalDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .onChange(of: internalDate) { dateString = formatDate($0) }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
            }
        }
        .onAppear { if let date = parseDate(from: dateString) { internalDate = date } }
    }
    
    private func formatDate(_ date: Date) -> String {
        DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .none)
    }
    
    private func parseDate(from text: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.date(from: text)
    }
    
    private func validateAndUpdateDate(from text: String) {
        if let date = parseDate(from: text) { internalDate = date }
    }
    
    private func isValidDate(_ text: String) -> Bool {
        parseDate(from: text) != nil
    }
}


struct DateInputField_Previews: PreviewProvider {
    static var previews: some View {
        DateInputField(dateString: .constant(""), placeholder: "Digite ou selecione a data")
    }
}
