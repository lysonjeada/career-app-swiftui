//
//  PasswordResetViewModel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 27/08/26.
//

import Foundation

/// ViewModel único para o fluxo inteiro de "esqueci minha senha"
/// (e-mail -> código -> nova senha). Uma instância é criada pelo
/// Coordinator e compartilhada pelas 3 telas (mesmo padrão de
/// `jobApplicationTrackerListViewModel`), assim o reset token emitido
/// depois da verificação do código fica só em memória aqui — nunca
/// passa pelo `AppPages`/`NavigationPath` do Coordinator.
@MainActor
final class PasswordResetViewModel: ObservableObject {
    @Published private(set) var email = ""

    @Published private(set) var isRequestingCode = false
    @Published var requestCodeErrorMessage: String?

    @Published private(set) var isVerifyingCode = false
    @Published var verifyCodeErrorMessage: String?
    @Published private(set) var resendRemainingSeconds = 0

    @Published private(set) var isResettingPassword = false
    @Published var resetPasswordErrorMessage: String?

    /// Só existe entre a verificação do código e a conclusão da troca
    /// de senha — nunca persistido, nunca logado, nunca exposto fora
    /// deste ViewModel.
    private var resetToken: String?

    private let service: AuthenticationServiceProtocol
    private var countdownTask: Task<Void, Never>?

    var canResend: Bool {
        resendRemainingSeconds == 0 && !isRequestingCode
    }

    init(
        service: AuthenticationServiceProtocol = AuthenticationService()
    ) {
        self.service = service
    }

    /// Chamado toda vez que o fluxo é iniciado do zero (Login ->
    /// "Esqueci minha senha"), pra não herdar estado de uma tentativa
    /// anterior abandonada.
    func reset() {
        email = ""
        resetToken = nil

        isRequestingCode = false
        requestCodeErrorMessage = nil

        isVerifyingCode = false
        verifyCodeErrorMessage = nil

        isResettingPassword = false
        resetPasswordErrorMessage = nil

        countdownTask?.cancel()
        resendRemainingSeconds = 0
    }

    private func isValidEmail(_ value: String) -> Bool {
        let normalized = value.trimmingCharacters(in: .whitespaces)
        return normalized.contains("@") && normalized.contains(".")
    }

    @discardableResult
    func requestPasswordReset(email: String) async -> Bool {
        guard !isRequestingCode else { return false }

        let normalizedEmail = email.trimmingCharacters(in: .whitespaces)

        guard isValidEmail(normalizedEmail) else {
            requestCodeErrorMessage = "Por favor, insira um e-mail válido."
            return false
        }

        isRequestingCode = true
        requestCodeErrorMessage = nil
        defer { isRequestingCode = false }

        do {
            _ = try await service.requestPasswordReset(
                email: normalizedEmail
            )

            self.email = normalizedEmail
            startCountdown(seconds: 60)

            return true

        } catch {
            requestCodeErrorMessage = error.localizedDescription
            return false
        }
    }

    @discardableResult
    func resendCode() async -> Bool {
        guard canResend else { return false }
        return await requestPasswordReset(email: email)
    }

    @discardableResult
    func verifyCode(_ code: String) async -> Bool {
        guard !isVerifyingCode else { return false }

        guard code.count == 6, code.allSatisfy(\.isNumber) else {
            verifyCodeErrorMessage = "Digite o código de seis dígitos."
            return false
        }

        isVerifyingCode = true
        verifyCodeErrorMessage = nil
        defer { isVerifyingCode = false }

        do {
            let response = try await service.verifyPasswordResetCode(
                email: email,
                code: code
            )

            resetToken = response.resetToken
            return true

        } catch {
            verifyCodeErrorMessage = error.localizedDescription
            return false
        }
    }

    @discardableResult
    func resetPassword(
        newPassword: String,
        confirmPassword: String
    ) async -> Bool {
        guard !isResettingPassword else { return false }

        guard !newPassword.isEmpty else {
            resetPasswordErrorMessage = "Digite a nova senha."
            return false
        }

        guard newPassword.count >= 8 else {
            resetPasswordErrorMessage =
                "A senha deve ter no mínimo 8 caracteres."
            return false
        }

        guard newPassword == confirmPassword else {
            resetPasswordErrorMessage = "As senhas não coincidem."
            return false
        }

        guard let resetToken else {
            resetPasswordErrorMessage =
                "Sessão de redefinição expirada. Solicite um novo código."
            return false
        }

        isResettingPassword = true
        resetPasswordErrorMessage = nil
        defer { isResettingPassword = false }

        do {
            _ = try await service.resetPassword(
                resetToken: resetToken,
                newPassword: newPassword
            )

            self.resetToken = nil
            return true

        } catch {
            resetPasswordErrorMessage = error.localizedDescription
            return false
        }
    }

    private func startCountdown(seconds: Int) {
        countdownTask?.cancel()
        resendRemainingSeconds = max(0, seconds)

        countdownTask = Task {
            while resendRemainingSeconds > 0 && !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                resendRemainingSeconds -= 1
            }
        }
    }

    deinit {
        countdownTask?.cancel()
    }
}
