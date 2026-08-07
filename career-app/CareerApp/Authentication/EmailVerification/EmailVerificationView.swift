//
//  EmailVerificationView.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 05/08/26.
//

import SwiftUI

struct EmailVerificationView: View {
    @FocusState
    private var codeFieldFocused: Bool

    @StateObject
    private var viewModel:
        EmailVerificationViewModel

    let email: String
    let onVerified: () -> Void
    let goBack: () -> Void

    init(
        email: String,
        onVerified: @escaping () -> Void,
        goBack: @escaping () -> Void,
        service:
            EmailVerificationServiceProtocol =
            EmailVerificationService()
    ) {
        self.email = email
        self.onVerified = onVerified
        self.goBack = goBack

        _viewModel = StateObject(
            wrappedValue:
                EmailVerificationViewModel(
                    email: email,
                    service: service
                )
        )
    }

    var body: some View {
        ZStack {
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

            if viewModel.viewState == .loading {
                loadingOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(
                placement:
                    .navigationBarLeading
            ) {
                Button(action: goBack) {
                    Image(
                        systemName:
                            "chevron.left"
                    )
                    .font(
                        .system(
                            size: 18,
                            weight: .medium
                        )
                    )
                    .foregroundColor(
                        .persianBlue
                    )
                }
            }
        }
        .onAppear {
            codeFieldFocused = true
        }
        .onChange(
            of: viewModel.viewState
        ) { _, newState in
            guard newState == .verified else {
                return
            }

            codeFieldFocused = false
            onVerified()
        }
    }

    private var header: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(
                        Color.persianBlue
                            .opacity(0.12)
                    )
                    .frame(
                        width: 88,
                        height: 88
                    )

                Image(
                    systemName:
                        "envelope.badge.shield.half.filled"
                )
                .font(
                    .system(size: 38)
                )
                .foregroundColor(
                    .persianBlue
                )
            }

            Text("Verifique seu e-mail")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(
                    .persianBlue
                )
                .multilineTextAlignment(
                    .center
                )

            Text(
                """
                Enviamos um código de seis dígitos para \(maskedEmail).
                """
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
                    get: {
                        viewModel.code
                    },
                    set: {
                        viewModel.updateCode($0)
                    }
                )
            )
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            .focused(
                $codeFieldFocused
            )
            .opacity(0.01)
            .frame(height: 1)

            HStack(spacing: 10) {
                ForEach(0..<6, id: \.self) {
                    index in

                    codeDigitBox(
                        index: index
                    )
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                codeFieldFocused = true
            }
        }
    }

    private func codeDigitBox(
        index: Int
    ) -> some View {
        let characters =
            Array(viewModel.code)

        let digit =
            index < characters.count
            ? String(characters[index])
            : ""

        let isCurrent =
            index == characters.count

        return Text(digit)
            .font(
                .system(
                    size: 24,
                    weight: .bold,
                    design: .rounded
                )
            )
            .frame(
                maxWidth: .infinity,
                minHeight: 58
            )
            .background(
                Color(
                    uiColor:
                        .secondarySystemBackground
                )
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 12
                )
            )
            .overlay {
                RoundedRectangle(
                    cornerRadius: 12
                )
                .stroke(
                    isCurrent
                    ? Color.persianBlue
                    : Color.gray.opacity(0.25),
                    lineWidth:
                        isCurrent ? 2 : 1
                )
            }
    }

    @ViewBuilder
    private var feedbackContent:
        some View {

        if let error =
            viewModel.errorMessage {

            Label(
                error,
                systemImage:
                    "exclamationmark.circle.fill"
            )
            .font(.footnote)
            .foregroundStyle(.red)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )

        } else if let success =
            viewModel.successMessage {

            Label(
                success,
                systemImage:
                    "checkmark.circle.fill"
            )
            .font(.footnote)
            .foregroundStyle(.green)
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
        }
    }

    private var verifyButton: some View {
        Button {
            codeFieldFocused = false
            viewModel.verify()
        } label: {
            Text("Verificar código")
                .fontWeight(.semibold)
                .frame(
                    maxWidth: .infinity
                )
                .padding()
                .background(
                    viewModel.canVerify
                    ? Color.persianBlue
                    : Color.gray.opacity(0.4)
                )
                .foregroundColor(.white)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 12
                    )
                )
        }
        .disabled(
            !viewModel.canVerify
        )
    }

    private var resendButton: some View {
        VStack(spacing: 10) {
            Text(
                "Não recebeu o código?"
            )
            .font(.footnote)
            .foregroundStyle(.secondary)

            Button {
                viewModel.resendCode()
            } label: {
                if viewModel.canResend {
                    Text("Reenviar código")
                } else {
                    Text(
                        """
                        Reenviar em \(viewModel.resendRemainingSeconds)s
                        """
                    )
                }
            }
            .fontWeight(.semibold)
            .foregroundColor(
                viewModel.canResend
                ? .persianBlue
                : .gray
            )
            .disabled(
                !viewModel.canResend
            )
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()

            ProgressView()
                .controlSize(.large)
                .padding(28)
                .background(
                    .regularMaterial
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 16
                    )
                )
        }
    }

    private var maskedEmail: String {
        let parts = email.split(
            separator: "@",
            maxSplits: 1
        )

        guard parts.count == 2 else {
            return email
        }

        let name = String(parts[0])
        let domain = String(parts[1])

        guard name.count > 2 else {
            return (
                "\(name.prefix(1))***@\(domain)"
            )
        }

        return (
            "\(name.prefix(2))***@\(domain)"
        )
    }
}
