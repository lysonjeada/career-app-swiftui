//
//  EditJobApplicationViewModelTests.swift
//  career-app
//

import Testing
@testable import career_app

@Suite
struct EditJobApplicationViewModelTests {
    @Test @MainActor
    func testInit_SetsDefaultLoadingState() {
        // Arrange & Act
        let service = JobApplicationServiceMock(isSuccess: true)
        let viewModel = EditJobApplicationViewModel(service: service)

        // Assert
        // A ViewModel ainda não expõe nenhum método além do estado inicial.
        #expect(viewModel.viewState == .loading)
    }
}
