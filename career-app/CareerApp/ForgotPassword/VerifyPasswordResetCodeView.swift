//
//  VerifyPasswordResetCodeView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 27/08/26.
//

import SwiftUI

struct VerifyPasswordResetCodeView: View {
    @FocusState private var codeFieldFocused: Bool
    @State private var code = ""

    @ObservedObject var viewModel: PasswordResetViewModel

    var goBack: () -> Void
    var onVerified: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                header
                codeInput
                feedbackContent
                verifyButton
                resendButton
            }
            .padding(.horizontal, 28)
            .padding(.top, 40)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: goBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.persianBlue)
                }
            }
        }
        .onAppear {
            codeFieldFocused = true
        }
    }

    private var header: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.persianBlue.opacity(0.12))
                    .frame(width: 88, height: 88)

                Image(systemName: "envelope.badge.shield.half.filled")
                    .font(.system(size: 38))
                    .foregroundColor(.persianBlue)
            }

            Text("Verifique seu e-mail")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.persianBlue)
                .multilineTextAlignment(.center)

            Text(
                "Enviamos um código de seis dígitos para \(maskedEmail)."
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
    }

    private var codeInput: some View {
        ZStack {
            TextField(
                "",
                text: Binding(
                    get: { code },
                    set: { newValue in
                        code = String(
                            newValue.filter(\.isNumber).prefix(6)
                        )
                        viewModel.verifyCodeErrorMessage = nil
                    }
                )
            )
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            .focused($codeFieldFocused)
            .opacity(0.01)
            .frame(height: 1)

            HStack(spacing: 10) {
                ForEach(0..<6, id: \.self) { index in
                    codeDigitBox(index: index)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                codeFieldFocused = true
            }
        }
    }

    private func codeDigitBox(index: Int) -> some View {
        let characters = Array(code)
        let digit = index < characters.count
            ? String(characters[index])
            : ""
        let isCurrent = index == characters.count

        return Text(digit)
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .frame(maxWidth: .infinity, minHeight: 58)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isCurrent
                            ? Color.persianBlue
                            : Color.gray.opacity(0.25),
                        lineWidth: isCurrent ? 2 : 1
                    )
            }
    }

    @ViewBuilder
    private var feedbackContent: some View {
        if let error = viewModel.verifyCodeErrorMessage {
            Label(error, systemImage: "exclamationmark.circle.fill")
                .font(.footnote)
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var canVerify: Bool {
        code.count == 6
            && code.allSatisfy(\.isNumber)
            && !viewModel.isVerifyingCode
    }

    private var verifyButton: some View {
        Button {
            codeFieldFocused = false

            Task {
                let succeeded = await viewModel.verifyCode(code)
                if succeeded {
                    onVerified()
                }
            }
        } label: {
            HStack {
                if viewModel.isVerifyingCode {
                    ProgressView()
                        .tint(.white)
                }

                Text("Verificar código")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                canVerify ? Color.persianBlue : Color.gray.opacity(0.4)
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!canVerify)
    }

    private var resendButton: some View {
        VStack(spacing: 10) {
            Text("Não recebeu o código?")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Button {
                Task {
                    await viewModel.resendCode()
                }
            } label: {
                if viewModel.canResend {
                    Text("Reenviar código")
                } else {
                    Text("Reenviar em \(viewModel.resendRemainingSeconds)s")
                }
            }
            .fontWeight(.semibold)
            .foregroundColor(viewModel.canResend ? .persianBlue : .gray)
            .disabled(!viewModel.canResend)
        }
    }

    private var maskedEmail: String {
        let parts = viewModel.email.split(separator: "@", maxSplits: 1)

        guard parts.count == 2 else {
            return viewModel.email
        }

        let name = String(parts[0])
        let domain = String(parts[1])

        guard name.count > 2 else {
            return "\(name.prefix(1))***@\(domain)"
        }

        return "\(name.prefix(2))***@\(domain)"
    }
}

#Preview {
    NavigationView {
        VerifyPasswordResetCodeView(
            viewModel: PasswordResetViewModel(),
            goBack: {},
            onVerified: {}
        )
    }
}
