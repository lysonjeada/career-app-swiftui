//
//  ProgressDashboardComponents.swift
//  career-app
//
//  Created by Amaryllis Baldrez on 31/07/26.
//

import Charts
import SwiftUI

struct DashboardPeriodPicker: View {
    let selectedMonths: Int
    let changeAction: (Int) -> Void

    private let periods = [
        3,
        6,
        12,
    ]

    var body: some View {
        Picker(
            "Período",
            selection: Binding(
                get: {
                    selectedMonths
                },
                set: {
                    changeAction($0)
                }
            )
        ) {
            ForEach(
                periods,
                id: \.self
            ) { months in
                Text("\(months) meses")
                    .tag(months)
            }
        }
        .pickerStyle(.segmented)
    }
}
