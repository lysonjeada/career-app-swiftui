//
//  AutoScroller.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 15/01/25.
//

import SwiftUI

fileprivate struct ItemSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = CGSize(width: max(value.width, nextValue().width),
                       height: max(value.height, nextValue().height))
    }
}

struct CarouselItem: Identifiable, Equatable {
    let cardType: CardType
    let image: String
    let description: String
    let buttonTitle: String
    let action: () -> Void
    var id: String
    
    enum CardType {
        case leading
        case center
    }
    
    init(
        cardType: CardType = .center,
        image: String,
        description: String,
        buttonTitle: String,
        action: @escaping () -> Void
    ) {
        self.cardType = cardType
        self.image = image
        self.description = description
        self.buttonTitle = buttonTitle
        self.action = action
        self.id = UUID().uuidString
    }
    
    static func == (lhs: CarouselItem, rhs: CarouselItem) -> Bool {
        return lhs.cardType == rhs.cardType &&
        lhs.image == rhs.image &&
        lhs.description == rhs.description &&
        lhs.buttonTitle == rhs.buttonTitle &&
        lhs.id == rhs.id
    }
}

import SwiftUI

struct AutoScroller: View {
    var items: [CarouselItem]
    let timer = Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()
    @State private var selectedIndex: Int = 0
    let autoScrollInterval: TimeInterval = 3.0 // Intervalo para auto-scroll
    
    var body: some View {
        VStack {
                TabView(selection: $selectedIndex) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        buildCarouselItem(item: item)
                            .padding(.horizontal, 8)
                            .tag(index) // Garante a indexação correta
                    }
                }
                .frame(maxHeight: .infinity)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onReceive(timer) { _ in
                    autoScroll()
                }
            buildCapsules()
                .frame(alignment: .top)
        }
        .frame(maxHeight: .infinity)
    }
    
    // MARK: - ViewBuilders
    
    @ViewBuilder
    private func buildCarouselItem(item: CarouselItem) -> some View {
        VStack(spacing: 16) {
            switch item.cardType {
            case .center:
                buildLeading(item: item)
//                buildCenter(item: item)
            case .leading:
                buildLeading(item: item)
            }
            
        }
        
        .background(VisualEffect(style: .systemThickMaterial))
        .cornerRadius(15)
        .shadow(radius: 10)
    }
    
    @ViewBuilder
    private func buildCapsules() -> some View {
        HStack(spacing: 8) {
            ForEach(items.indices, id: \.self) { index in
                Capsule()
                    .fill(Color.persianBlue.opacity(selectedIndex == index ? 1 : 0.33))
                    .frame(width: 35, height: 8)
                    .onTapGesture {
                        withAnimation {
                            selectedIndex = index
                        }
                    }
            }
        }
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private func buildLeading(item: CarouselItem) -> some View {
        HStack {
            Image(item.image)
            //                    .resizable()
            //                    .scaledToFill()
            //                    .frame(maxHeight: 160)
            //                .clipped()
                .cornerRadius(10)
            Text(item.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.top, 24)
        Button(action: item.action) {
            Text(item.buttonTitle)
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.persianBlue)
                .foregroundColor(.white)
                .cornerRadius(8)
        }
        .padding(.bottom, 16)
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private func buildCenter(item: CarouselItem) -> some View {
        VStack {
            Image(item.image)
            //                        .resizable()
            //                        .scaledToFill()
            //                    .frame(maxHeight: 160)
            //                .clipped()
                .cornerRadius(10)
            Text(item.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button(action: item.action) {
                Text(item.buttonTitle)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        
    }
    
    // MARK: - Helper Methods
    
    private func autoScroll() {
        //            withAnimation {
        //                selectedIndex = (selectedIndex + 1) % items.count
        //            }
    }
}


#Preview {
    AutoScroller(
        items: [
            CarouselItem(
                image: "resume-image",
                description: "Create a stunning resume with our powerful tools.",
                buttonTitle: "Learn More",
                action: { print("Resume button tapped") }
            ),
            CarouselItem(
                cardType: CarouselItem.CardType.leading,
                image: "generate-image",
                description: "Generate interview questions tailored to your skills.",
                buttonTitle: "Generate Now",
                action: { print("Generate button tapped") }
            ),
            CarouselItem(
                image: "generate-resume",
                description: "Explore our tools to help you achieve career success.",
                buttonTitle: "Explore",
                action: { print("Explore button tapped") }
            )
        ])
}


struct VisualEffect: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
