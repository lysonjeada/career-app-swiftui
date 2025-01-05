//
//  Carousel.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 31/12/24.
//

import SwiftUI

fileprivate struct ItemSizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = CGSize(width: max(value.width, nextValue().width),
                       height: max(value.height, nextValue().height))
    }
}

public enum CarouselStyle: String, Codable, CaseIterable {
    case large
    
    var widthPercentage: CGFloat {
        switch self {
        case .large:
            1
        }
    }
    
    var spacing: CGFloat {
        switch self {
        case .large:
            1
        }
    }
}

public struct Carousel<Content: View, T: Identifiable>: View {
    @Binding private var index: Int
    @Binding private var currentIndex: Int
    @Binding private var buttonsEnabled: Bool
    @State private var contentHeight: CGFloat = 0
    @GestureState private var offset: CGFloat = .zero
    
    private let style: CarouselStyle
    private let carouselSpaceBetweenItems: Bool
    private let items: [T]
    private var content: (T) -> Content
    private var onSwipe: (_ currentIndex: Int) -> Void
    
    public init(
        index: Binding<Int>,
        currentIndex: Binding<Int> = .constant(0),
        buttonsEnabled: Binding<Bool> = .constant(true),
        carouselSpaceBetweenItems: Bool = true,
        items: [T],
        @ViewBuilder content: @escaping (T) -> Content,
        onSwipe: @escaping (Int) -> Void = { _ in }
    ) {
        self._index = index
        self._currentIndex = currentIndex
        self._buttonsEnabled = buttonsEnabled
        self.carouselSpaceBetweenItems = carouselSpaceBetweenItems
        self.items = items
        self.content = content
        self.onSwipe = onSwipe
        self.style = .large
    }
    
    var isFirstTab: Bool {
        currentIndex == 0
    }
    
    private var isSingle: Bool {
        items.count == 1
    }
    
    public var body: some View {
        VStack(spacing: carouselSpaceBetweenItems ? 16 : .zero) {
            GeometryReader { proxy in
                let proxyWidth = proxy.size.width
                let trailingSpace = proxyWidth * (1 - style.widthPercentage)
                let width = proxyWidth - trailingSpace
                let ajustmentWidth = trailingSpace / 2
                
                HStack(spacing: carouselSpaceBetweenItems ? style.spacing : .zero) {
                    ForEach(items) { item in
                        content(item)
                            .frame(width: proxyWidth - trailingSpace + (isSingle ? style.spacing : .zero))
                            .background(
                                GeometryReader { innerProxy in
                                    Color.clear.preference(key: ItemSizePreferenceKey.self, value: innerProxy.size)
                                }
                            )
                    }
                }
                .onPreferenceChange(ItemSizePreferenceKey.self) { newSize in
                    contentHeight = newSize.height
                }
                .offset(x: (CGFloat(currentIndex) * -width) + (!isFirstTab ? ajustmentWidth : .zero) + offset)
                .highPriorityGesture(
                    DragGesture()
                        .updating($offset, body: { value, out, _ in
                            out = value.translation.width
                        })
                        .onEnded({ value in
                            let offsetX = value.translation.width * 1.65
                            let progress = -offsetX / width
                            let newIndex: Int
                            
                            if progress >= 0.35 {
                                newIndex = min(currentIndex + 1, items.count - 1)
                            } else if progress < -0.35 {
                                newIndex = max(currentIndex - 1, 0)
                            } else {
                                newIndex = currentIndex
                            }

                            // Animação explícita ao alterar o índice
                            withAnimation(.easeInOut) {
                                currentIndex = newIndex
                            }
                            
                            onSwipe(currentIndex)
                        })
                        .onChanged({ value in
                            let offsetX = value.translation.width * 1.65
                            let progress = -offsetX / width
                            let roundedProgress = Int(progress.rounded())
                            
                            // Atualização do índice com animação suave
                            withAnimation(.easeInOut) {
                                index = max(min(currentIndex + roundedProgress, items.count - 1), 0)
                            }
                        })
                )

//                .highPriorityGesture(
//                    DragGesture()
//                        .updating($offset, body: { value, out, _ in
//                            out = value.translation.width
//                        })
//                        .onEnded({ value in
//                            let offsetX = value.translation.width * 1.65
//                            let velocityX = value.velocity.width
//                            let progress = -offsetX / width
//                            
//                            let shortSwipeThresold: CGFloat = 20
//                            let longSwipeThresold: CGFloat = 0.35
//                            
//                            if abs(offsetX) > shortSwipeThresold && abs(velocityX) > 400 {
//                                if offsetX > 0 {
//                                    currentIndex = max(currentIndex - 1, 0)
//                                } else {
//                                    currentIndex = min(currentIndex + 1, items.count - 1)
//                                }
//                            } else if progress >= longSwipeThresold {
//                                currentIndex = min(currentIndex + 1, items.count - 1)
//                            } else if progress < -longSwipeThresold {
//                                currentIndex = max(currentIndex - 1, 0)
//                            }
//                            onSwipe(currentIndex)
//                        })
//                        .onChanged({ value in
//                            let offsetX = value.translation.width * 1.65
//                            let progress = -offsetX / width
//                            let roundedProgress = Int(progress.rounded())
//                            index = max(min(currentIndex + roundedProgress, items.count - 1), 0)
//                        })
//                )
            }
            .frame(idealHeight: contentHeight)
            .animation(.easeInOut, value: currentIndex)
            
            if !isSingle {
                Indicator(
                    currentIndex: $currentIndex,
                    buttonsEnabled: $buttonsEnabled,
                    numberOfItems: items.count
                ) { _ in
                    onSwipe(currentIndex)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

struct Carousel_Previews: PreviewProvider {
    @State private static var currentIndex: Int = 0
    @State private static var isEnabled = true
    private static var viewModel: GenerateQuestionsViewModel {
        GenerateQuestionsViewModel()
    }
    
    static var previews: some View {
        Carousel(
            index: $currentIndex,
            currentIndex: $currentIndex,
            buttonsEnabled: $isEnabled,
            items: viewModel.steps
        ) { step in
                showTypeAndDescriptionJob(
                    title: step.title,
                    description: step.description,
                    imageButton: step.imageButton,
                    type: step.type
                )
        }
    }
    
    @ViewBuilder
    static func showTypeAndDescriptionJob(
        title: String,
        description: String?,
        imageButton: String,
        type: QuestionsGeneratorStep.Step.StepType
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.top, 8)
            
            if let description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            
            Button(action: {}) {
                HStack {
                    Image(systemName: imageButton)
                        .frame(width: 24, height: 24)
                    Text("+")
                        .bold()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
        }
        .padding(.horizontal, 16)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}
