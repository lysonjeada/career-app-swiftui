//
//  Indicator.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 31/12/24.
//

import SwiftUI

struct Indicator: View {
    @Binding private var currentIndex: Int
    @Binding private var buttonsEnabled: Bool
    
    private let numberOfItems: Int
    private let height: CGFloat = 40
    private let iconHeight: CGFloat = 12
    private var onClick: (Indicator) -> Void
    
    public init(currentIndex: Binding<Int>, buttonsEnabled: Binding<Bool>, numberOfItems: Int, onClick: @escaping (Indicator) -> Void = { _ in }) {
        self._currentIndex = currentIndex
        self._buttonsEnabled = buttonsEnabled
        self.numberOfItems = numberOfItems
        self.onClick = onClick
    }
    
    var isFirstTab: Bool {
        currentIndex == 0
    }
    
    private var isLastTab: Bool {
        currentIndex == numberOfItems - 1
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Spacer()
            Button(action: {
                currentIndex = currentIndex - 1
            }, label: {
                VStack {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: iconHeight)
                        .foregroundColor(isFirstTab ? Color.persianBlue.opacity(0.35) : Color.persianBlue)
                        .bold()
                    //                            .foregroundColor(isFirstTab ? Color.gray : Color.black)
                }
                .frame(width: height, height: height)
            })
            .frame(width: height, height: height)
            .disabled(isFirstTab)
            ForEach(0..<numberOfItems, id: \.self) { index in
                Circle()
                    .foregroundColor(index == currentIndex ? Color.persianBlue : Color.indicatorColor)
                    .frame(width: 8, height: 8)
            }
            Button(action: {
                currentIndex = currentIndex + 1
            }, label: {
                VStack {
                    Image(systemName: "chevron.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: iconHeight)
                        .foregroundColor(isLastTab ? Color.persianBlue.opacity(0.35) : Color.persianBlue)
                        .bold()
                    //                            .foregroundColor(isFirstTab ? Color.persianBlue : Color.backgroundGray)
                }
                .frame(width: height, height: height)
            })
            .frame(width: height, height: height)
            .disabled(isLastTab)
            Spacer()
        }
        .padding(8)
        .frame(height: height)
    }
}
