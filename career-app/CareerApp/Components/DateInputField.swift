//
//  DateInputField.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 13/01/25.
//

import SwiftUI

// Extensão para DateFormatter para consistência
extension DateFormatter {
    static let customShortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy" // Formato fixo para evitar problemas de localização
        formatter.locale = Locale(identifier: "pt_BR") // Opcional: para garantir o formato em PT_BR
        return formatter
    }()
}

struct DateInputField: View {
    @Binding var dateString: String
    @State private var showDatePicker = false
    // internalDate sempre terá um valor válido, inicialmente a data atual ou a data parseada da string.
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
                        .onChange(of: dateString) {
                            // Tenta atualizar internalDate quando dateString muda
                            if let date = DateFormatter.customShortDateFormatter.date(from: dateString) {
                                internalDate = date
                            }
                            // Não fazemos o TextField ficar vermelho automaticamente aqui
                            // se a data for inválida, apenas se o `isValidDate` disser.
                            // A cor vermelha será baseada no `isValidDate`
                        }
                        .keyboardType(.numbersAndPunctuation)
                        .padding(.leading, 12)
                        .padding(.vertical, 12)
                        .foregroundColor(isValidDate(dateString) || dateString.isEmpty ? .primary : .red) // Valida ou permite vazio
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
                // `DatePicker` pode ser flexível. Não há necessidade de definir `minimumDate` ou `maximumDate`
                // a menos que haja uma restrição de negócio.
                DatePicker(
                    "",
                    selection: $internalDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .onChange(of: internalDate) {
                    // Atualiza dateString quando internalDate muda (pelo DatePicker)
                    dateString = DateFormatter.customShortDateFormatter.string(from: internalDate)
                    showDatePicker = false // Esconde o picker após a seleção
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.top, 5) // Um pequeno padding para separar do TextField
            }
        }
        .onAppear {
            // No aparecimento, tenta inicializar internalDate com a data da string
            if let date = DateFormatter.customShortDateFormatter.date(from: dateString) {
                internalDate = date
            } else {
                // Se a string for inválida ou vazia, use a data atual como padrão para o picker
                internalDate = Date()
            }
        }
    }
    
    // Funções auxiliares, usando o DateFormatter consistente
    private func parseDate(from text: String) -> Date? {
        DateFormatter.customShortDateFormatter.date(from: text)
    }
    
    private func isValidDate(_ text: String) -> Bool {
        // Uma string vazia é considerada "válida" neste contexto para não ficar vermelha.
        // A validação de preenchimento obrigatório deve ser feita no formulário principal.
        text.isEmpty || parseDate(from: text) != nil
    }
}


struct DateInputField_Previews: PreviewProvider {
    static var previews: some View {
        DateInputField(dateString: .constant(""), placeholder: "Digite ou selecione a data")
    }
}
