//
//  AuthCoordinator.swift
//  career-app
//

import SwiftUI

/// Navegação do fluxo de autenticação (login, cadastro, esqueci minha
/// senha, verificação de email) — antes espalhada dentro do Coordinator
/// raiz. Empurra no `path` compartilhado do Coordinator raiz (não tem
/// NavigationStack própria), então continua saindo de qualquer aba
/// normalmente.
@MainActor
final class AuthCoordinator {
    weak var root: Coordinator?

    var loginViewModel = LoginViewModel()

    // Compartilhado pelas 3 telas do fluxo de "esqueci minha senha" — o
    // reset token emitido na verificação do código fica só em memória
    // aqui dentro, nunca precisa passar pelo path.
    var passwordResetViewModel = PasswordResetViewModel()

    func push(_ route: AuthRoute) {
        root?.path.append(route)
    }

    /// LoginView exibida como raiz (usuário deslogado) — sucesso não
    /// precisa dar pop, já que não há nada empilhado ainda.
    @ViewBuilder
    func buildRootLoginView() -> some View {
        LoginView(
            viewModel: self.loginViewModel,
            onLoginSuccess: { [weak self] userId in
                self?.root?.currentUserId = userId
                self?.root?.isLoggedIn = true
            },
            onVerificationRequired: { [weak self] email, username, password in
                self?.push(.emailVerification(email: email, username: username, password: password))
            }
        )
    }

    @ViewBuilder
    func build(_ route: AuthRoute) -> some View {
        switch route {
        case .login:
            LoginView(
                viewModel: self.loginViewModel,
                onLoginSuccess: { [weak self] userId in
                    self?.root?.currentUserId = userId
                    self?.root?.isLoggedIn = true
                    self?.root?.popToRoot()
                },
                onVerificationRequired: { [weak self] email, username, password in
                    self?.push(.emailVerification(email: email, username: username, password: password))
                }
            )

        case .signUp:
            let signUpViewModel = SignUpViewModel()

            SignUpView(
                viewModel: signUpViewModel,
                goToLogin: { [weak self] in
                    self?.root?.pop()
                },
                onVerificationRequired: { [weak self] email, username, password in
                    self?.push(.emailVerification(email: email, username: username, password: password))
                }
            )

        case .forgotPassword:
            ForgotPasswordView(
                viewModel: passwordResetViewModel,
                goToLogin: { [weak self] in self?.push(.login) },
                onCodeSent: { [weak self] in self?.push(.verifyPasswordResetCode) }
            )

        case .verifyPasswordResetCode:
            VerifyPasswordResetCodeView(
                viewModel: passwordResetViewModel,
                goBack: { [weak self] in self?.root?.pop() },
                onVerified: { [weak self] in self?.push(.resetPassword) }
            )

        case .resetPassword:
            ResetPasswordView(
                viewModel: passwordResetViewModel,
                goToLogin: { [weak self] in self?.goToLogin() }
            )

        case let .emailVerification(email, username, password):
            EmailVerificationView(
                email: email,
                onVerified: { [weak self] in
                    self?.completeVerifiedLogin(username: username, password: password)
                },
                goBack: { [weak self] in self?.root?.pop() }
            )
        }
    }

    private func goToLogin() {
        root?.path = NavigationPath()
        push(.login)
    }

    /// Faz o login automaticamente com as credenciais recém-digitadas
    /// assim que o código de verificação é confirmado — evita mandar o
    /// usuário de volta para a tela de login logo depois de cadastrar
    /// ou verificar a conta.
    private func completeVerifiedLogin(
        username: String,
        password: String
    ) {
        Task { [weak self] in
            guard let self else { return }

            if let response = await LoginViewModel().completeVerifiedLogin(
                username: username,
                password: password
            ) {
                self.root?.currentUserId = response.id.uuidString
                self.root?.isLoggedIn = true

            } else {
                // A conta já foi verificada; se o login automático
                // falhar (ex.: instabilidade de rede), o usuário ainda
                // consegue entrar manualmente com as mesmas credenciais.
                self.goToLogin()
            }
        }
    }
}

enum AuthRoute: Hashable {
    case login
    case signUp
    case forgotPassword
    case verifyPasswordResetCode
    case resetPassword
    case emailVerification(
        email: String,
        username: String,
        password: String
    )
}
