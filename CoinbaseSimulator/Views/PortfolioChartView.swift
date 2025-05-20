//
//  PortfolioChartView.swift
//  CoinbaseSimulator
//
//  Created by vincent helvie on 5/20/25.
//

import SwiftUI
import Charts

struct PortfolioChartView: View {
    let snapshots: [PortfolioSnapshot]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Portfolio Value Over Time")
                .font(.headline)
                .padding(.bottom, 4)

            if snapshots.count >= 2 {
                Chart(snapshots) { snapshot in
                    LineMark(
                        x: .value("Time", snapshot.timestamp),
                        y: .value("Value", snapshot.value)
                    )
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 200)
            } else {
                Text("Not enough data yet to display chart.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}
