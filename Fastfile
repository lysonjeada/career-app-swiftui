default_platform(:ios)

platform :ios do
  desc "Rodar os testes com Swift Package Manager"
  lane :test do
    sh("swift test --configuration debug")
  end

  desc "Build da aplicação com Swift Package Manager"
  lane :build do
    sh("swift build --configuration release")
  end

  desc "Rodar os testes no esquema de projeto iOS"
  lane :spm_test_ios do
    scan(
      scheme: "career-app",
      clean: true,
      build: true,
      test_without_building: false,
      devices: ["iPhone 12"]
    )
  end

  desc "Rodar os testes e gerar cobertura com SPM"
  lane :spm_test_coverage do
    sh("swift test --enable-code-coverage")
  end
end
