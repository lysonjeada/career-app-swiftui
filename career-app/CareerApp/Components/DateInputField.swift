//
//  DateInputField.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 13/01/25.
//

import SwiftUI

import SwiftUI

struct DateInputField: View {
    @Binding
    var dateString: String

    @State
    private var showDatePicker = false

    @State
    private var internalDate = Date()

    @State
    private var isDateStringValid = true

    let placeholder: String

    var body: some View {
        VStack {
            HStack {
                ZStack(
                    alignment: .leading
                ) {
                    if dateString.isEmpty {
                        Text(placeholder)
                            .foregroundColor(
                                Color(.systemGray)
                            )
                            .padding(
                                .leading,
                                12
                            )
                    }

                    TextField(
                        "",
                        text: $dateString
                    )
                    .onChange(
                        of: dateString
                    ) {
                        oldValue,
                        newValue in

                        let formatted =
                            formatInputDate(
                                newValue
                            )

                        if formatted
                            != newValue {
                            dateString =
                                formatted

                            return
                        }

                        isDateStringValid =
                            isValidDate(
                                formatted
                            )
                            || formatted.isEmpty

                        if let date =
                            dateFromString(
                                formatted
                            ) {

                            internalDate =
                                date
                        }

                        print(
                            """
                            📅 DateInputField

                            String:
                            \(formatted)

                            Válida:
                            \(isDateStringValid)
                            """
                        )
                    }
                    .keyboardType(
                        .numbersAndPunctuation
                    )
                    .padding(
                        .leading,
                        12
                    )
                    .padding(
                        .vertical,
                        12
                    )
                    .foregroundColor(
                        isDateStringValid
                        ? .primary
                        : .red
                    )
                }
                .overlay {
                    RoundedRectangle(
                        cornerRadius: 8
                    )
                    .stroke(
                        Color.persianBlue,
                        lineWidth: 1
                    )
                }
                .padding(
                    .trailing,
                    8
                )

                Button {
                    showDatePicker.toggle()
                } label: {
                    Image(
                        systemName:
                            "calendar"
                    )
                    .resizable()
                    .frame(
                        width: 24,
                        height: 24
                    )
                    .foregroundColor(
                        .persianBlue
                    )
                }
            }

            if showDatePicker {
                DatePicker(
                    "",
                    selection:
                        $internalDate,
                    displayedComponents:
                        .date
                )
                .datePickerStyle(
                    .graphical
                )
                .onChange(
                    of: internalDate
                ) {
                    _,
                    newDate in

                    dateString =
                        stringFromDate(
                            newDate
                        )

                    isDateStringValid =
                        true

                    print(
                        """
                        🗓️ Data escolhida no DatePicker:
                        \(dateString)
                        """
                    )

                    showDatePicker =
                        false
                }
                .background(
                    Color(
                        .systemBackground
                    )
                )
                .cornerRadius(12)
                .padding(
                    .top,
                    5
                )
            }
        }
        .onAppear {
            if let date =
                dateFromString(
                    dateString
                ) {

                internalDate =
                    date
            }
        }
    }

    // MARK: - Picker → String

    private func stringFromDate(
        _ date: Date
    ) -> String {
        let calendar =
            Calendar.current

        let components =
            calendar.dateComponents(
                [
                    .day,
                    .month,
                    .year
                ],
                from: date
            )

        guard
            let day =
                components.day,
            let month =
                components.month,
            let year =
                components.year
        else {
            return ""
        }

        return String(
            format:
                "%02d/%02d/%04d",
            day,
            month,
            year
        )
    }

    // MARK: - String → Date

    private func dateFromString(
        _ value: String
    ) -> Date? {
        let components =
            value.split(
                separator: "/"
            )

        guard components.count == 3,
              let day =
                Int(components[0]),
              let month =
                Int(components[1]),
              let year =
                Int(components[2])
        else {
            return nil
        }

        var dateComponents =
            DateComponents()

        dateComponents.year =
            year

        dateComponents.month =
            month

        dateComponents.day =
            day

        /*
         Usamos meio-dia em vez de meia-noite.
         Isso evita problemas de mudança de dia
         causados por timezone/DST.
         */
        dateComponents.hour = 12

        return Calendar.current.date(
            from: dateComponents
        )
    }

    // MARK: - Formatting

    private func formatInputDate(
        _ input: String
    ) -> String {
        var cleanedString =
            input.filter {
                $0.isNumber
            }

        if cleanedString.count > 8 {
            cleanedString =
                String(
                    cleanedString
                        .prefix(8)
                )
        }

        var formattedString = ""

        for (
            index,
            character
        ) in cleanedString
            .enumerated() {

            formattedString.append(
                character
            )

            if index == 1,
               cleanedString.count > 2 {

                formattedString.append(
                    "/"
                )
            }

            if index == 3,
               cleanedString.count > 4 {

                formattedString.append(
                    "/"
                )
            }
        }

        return formattedString
    }

    // MARK: - Validation

    private func isValidDate(
        _ value: String
    ) -> Bool {
        guard !value.isEmpty else {
            return true
        }

        let components =
            value.split(
                separator: "/"
            )

        guard components.count == 3,
              let day =
                Int(components[0]),
              let month =
                Int(components[1]),
              let year =
                Int(components[2])
        else {
            return false
        }

        var dateComponents =
            DateComponents()

        dateComponents.year =
            year

        dateComponents.month =
            month

        dateComponents.day =
            day

        var calendar =
            Calendar(
                identifier: .gregorian
            )

        calendar.timeZone =
            TimeZone(
                secondsFromGMT: 0
            )!

        guard let date =
                calendar.date(
                    from: dateComponents
                )
        else {
            return false
        }

        return (
            calendar.component(
                .day,
                from: date
            ) == day
            &&
            calendar.component(
                .month,
                from: date
            ) == month
            &&
            calendar.component(
                .year,
                from: date
            ) == year
        )
    }
}

extension String {
    func backendDateToDayMonthString() -> String? {
        let components = split(
            separator: "-"
        )

        guard components.count == 3,
              components[0].count == 4,
              components[1].count == 2,
              components[2].count == 2
        else {
            print(
                """
                ❌ Data backend inválida:
                \(self)
                """
            )

            return nil
        }

        let month = components[1]
        let day = components[2]

        let result =
            "\(day)/\(month)"

        print(
            """
            📅 Conversão sem timezone:
            Backend: \(self)
            Display: \(result)
            """
        )

        return result
    }
}

struct DateInputField_Previews: PreviewProvider {
    static var previews: some View {
        DateInputField(dateString: .constant(""), placeholder: "Digite ou selecione a data")
    }
}
