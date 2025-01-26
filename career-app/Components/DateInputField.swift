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
                            .foregroundColor(Color.persianBlue.opacity(0.5))
                            .padding(.leading, 12)
                    }

                    TextField("", text: $dateString)
                        .onChange(of: dateString) { newValue in
                            validateAndUpdateDate(from: newValue)
                        }
                        .keyboardType(.numbersAndPunctuation)
                        .padding(.leading, 12)
                        .padding(.vertical, 12)
                        .foregroundColor(isValidDate(dateString) ? .persianBlue : .red)
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
                VStack(alignment: .leading) {
                    DatePicker(
                        "",
                        selection: $internalDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    .onChange(of: internalDate) { newDate in
                        dateString = formatDate(newDate)
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                }
            }
        }
        .onAppear {
            if let parsedDate = parseDate(from: dateString) {
                internalDate = parsedDate
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: date)
    }

    private func parseDate(from text: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.date(from: text)
    }

    private func validateAndUpdateDate(from text: String) {
        if let parsedDate = parseDate(from: text) {
            internalDate = parsedDate
        }
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
