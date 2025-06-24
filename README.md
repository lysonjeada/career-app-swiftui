# 📱 Documentação de Componentes Visuais - Tela de Perfil
Esta documentação descreve os principais componentes visuais usados na tela ProfileView, incluindo estilos, funcionalidades e usos de cores customizadas.

### 🎨 Paleta de Cores
| Nome da Cor        | Descrição                       |
|--------------------|---------------------------------|
| Color.persianBlue | Azul predominante na interface (usado em botões, títulos e detalhes) |
| Color.backgroundLightGray | Cor de fundo para áreas gerais da tela |

### 🧩 Componentes Personalizados
### 1. CustomTextField
> Campo de texto com estilo consistente para entradas de usuário.
Características:
- Padding interno
- Fundo com opacidade baixa na cor .persianBlue
- Cor do texto, placeholder e cursor em tons de azul
- Label acima do campo com o placeholder como título
Exemplo de uso:
```swift
CustomTextField("Nome", text: $name)
```

### 2. PersianBlueTextFieldStyle
> Um TextFieldStyle customizado aplicado dentro do CustomTextField.
Estilo aplicado:
- Padding
- Fundo com .persianBlue.opacity(0.1)
- Texto e cursor na cor .persianBlue
- Cantos arredondados

### 3. SectionView
> Agrupador visual de seções com título.
Características:
Título em azul, fonte bold, tamanho 20
Espaçamento vertical entre título e campos
Padding horizontal
Uso de VStack com alinhamento personalizável (default: .center)
Exemplo de uso:
```swift
SectionView(title: "Informações pessoais") {
    CustomTextField("Nome", text: $name)
    // ...
}
```

### 4. ActionButton
> Botão com suporte a estado de loading (ProgressView).
Propriedades:
Título customizável
Suporte a estado isLoading
Cor de fundo configurável
Altura mínima garantida para consistência visual
Animação suave na transição de loading
Exemplo de uso:
```swift
ActionButton(
    title: isSaving ? "Salvando..." : "Salvar",
    isLoading: isSaving,
    color: .persianBlue,
    action: { saveProfile() }
)
```

### 5. Profile Image Section (profileImageSection)
> Área superior da tela para exibição e edição da imagem de perfil.
Elementos internos:
Imagem circular com clipShape(Circle())
Borda azul em volta quando não há imagem
Ícone de câmera sobreposto no canto inferior direito
Botão de excluir (lixeira vermelha) que aparece apenas quando o usuário já tem uma imagem carregada
### 6. Toolbar Customizada (navigationConfig)
> Modificador de View para configurar o título da NavigationBar e botão de voltar.
Características:
Título centralizado em branco e bold
Fundo da NavigationBar com .persianBlue
Botão de voltar customizado com chevron.left + label "Voltar"
Exemplo de uso:
.navigationConfig(title: "Profile", backAction: { coordinator.pop() })
### 7. Error Handling (errorAlert)
> Extensão para exibir um Alert de erro, caso o saveProfile() ou o delete da imagem falhe.
Exemplo de uso:
.errorAlert(isPresented: $showErrorAlert, message: errorMessage)
### 8. ImagePicker (UIKit integration)
> Um wrapper em SwiftUI para o UIImagePickerController e TOCropViewController (ou outro cropper que você estiver usando), apresentado como .sheet.
Fluxo:
Abre a galeria.
Permite seleção e cropping da imagem.
Atualiza os bindings profileImage e imageData.
### ✅ Fluxo visual geral da tela
ScrollView
├── Profile Image Section (com Camera Icon + Botão Delete)
├── Section: Informações pessoais
│    ├── CustomTextField: Nome
│    ├── CustomTextField: Experiência
│    └── CustomTextField: Instituição
├── Section: Links
│    ├── CustomTextField: GitHub
│    └── CustomTextField: Portfólio
├── HStack:
│    ├── ActionButton: Salvar (com loading)
│    └── ActionButton: Excluir
└── Error Alert
### 🚩 Possíveis Melhorias Futuras:
✅ Adicionar Feedback de sucesso após salvar
✅ Implementar ação de exclusão de perfil
✅ Suporte a captura de foto direto da câmera
