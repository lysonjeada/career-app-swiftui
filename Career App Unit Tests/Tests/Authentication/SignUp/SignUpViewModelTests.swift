//
//  SignUpViewModelTests.swift
//  career-app
//

import Testing
@testable import career_app

@Suite
struct SignUpViewModelTests {
    @Test @MainActor
    func testRegisterUser_Success_SetsLoadedStateAndRegisteredEmail() async throws {
        // Arrange
        let service = AuthenticationServiceMock(isSuccess: true)
        let viewModel = SignUpViewModel(service: service)

        // Act
        viewModel.registerUser(username: "usuario_teste", email: "novo.usuario@email.com", password: "senha123", confirmPassword: "senha123")
        try await awaitCondition(until: viewModel.viewState == .loaded, timeout: 5.0)

        // Assert
        #expect(viewModel.viewState == .loaded)
        #expect(viewModel.registeredEmail == "novo.usuario@email.com")
        #expect(viewModel.showSnackbar)
        if case .success = viewModel.snackbarType {
            // esperado
        } else {
            Issue.record("Esperava snackbarType .success, mas obteve \(viewModel.snackbarType)")
        }
        #expect(service.receivedRegisterRequest?.username == "usuario_teste")
        #expect(service.receivedRegisterRequest?.email == "novo.usuario@email.com")
    }

    @Test @MainActor
    func testRegisterUser_WithEmptyFields_ShowsInfoSnackbarWithoutCallingService() async throws {
        // Arrange
        let service = AuthenticationServiceMock(isSuccess: true)
        let viewModel = SignUpViewModel(service: service)

        // Act
        viewModel.registerUser(username: "", email: "", password: "", confirmPassword: "")

        // Assert
        #expect(viewModel.viewState == .idle)
        #expect(viewModel.snackbarMessage == "Por favor, preencha todos os campos.")
        if case .info = viewModel.snackbarType {
            // esperado
        } else {
            Issue.record("Esperava snackbarType .info, mas obteve \(viewModel.snackbarType)")
        }
        #expect(service.receivedRegisterRequest == nil)
    }

    @Test @MainActor
    func testRegisterUser_WithMismatchedPasswords_ShowsErrorSnackbar() async throws {
        // Arrange
        let service = AuthenticationServiceMock(isSuccess: true)
        let viewModel = SignUpViewModel(service: service)

        // Act
        viewModel.registerUser(username: "usuario_teste", email: "novo.usuario@email.com", password: "senha123", confirmPassword: "outrasenha")

        // Assert
        #expect(viewModel.snackbarMessage == "As senhas não coincidem.")
        if case .error = viewModel.snackbarType {
            // esperado
        } else {
            Issue.record("Esperava snackbarType .error, mas obteve \(viewModel.snackbarType)")
        }
        #expect(service.receivedRegisterRequest == nil)
    }

    @Test @MainActor
    func testRegisterUser_WithInvalidEmail_ShowsErrorSnackbar() async throws {
        // Arrange
        let service = AuthenticationServiceMock(isSuccess: true)
        let viewModel = SignUpViewModel(service: service)

        // Act
        viewModel.registerUser(username: "usuario_teste", email: "email-invalido", password: "senha123", confirmPassword: "senha123")

        // Assert
        #expect(viewModel.snackbarMessage == "Por favor, insira um e-mail válido.")
        #expect(service.receivedRegisterRequest == nil)
    }

    @Test @MainActor
    func testRegisterUser_WithShortPassword_ShowsErrorSnackbar() async throws {
        // Arrange
        let service = AuthenticationServiceMock(isSuccess: true)
        let viewModel = SignUpViewModel(service: service)

        // Act
        viewModel.registerUser(username: "usuario_teste", email: "novo.usuario@email.com", password: "123", confirmPassword: "123")

        // Assert
        #expect(viewModel.snackbarMessage == "A senha deve ter no mínimo 6 caracteres.")
        #expect(service.receivedRegisterRequest == nil)
    }

    @Test @MainActor
    func testRegisterUser_WhenServiceFails_SetsErrorStateWithSnackbar() async throws {
        // Arrange
        let service = AuthenticationServiceMock(isSuccess: false)
        let viewModel = SignUpViewModel(service: service)

        // Act
        viewModel.registerUser(username: "usuario_teste", email: "novo.usuario@email.com", password: "senha123", confirmPassword: "senha123")
        try await awaitCondition(until: viewModel.viewState == .error, timeout: 5.0)

        // Assert
        #expect(viewModel.viewState == .error)
        if case .error = viewModel.snackbarType {
            // esperado
        } else {
            Issue.record("Esperava snackbarType .error, mas obteve \(viewModel.snackbarType)")
        }
        #expect(viewModel.registeredEmail == nil)
    }
}
