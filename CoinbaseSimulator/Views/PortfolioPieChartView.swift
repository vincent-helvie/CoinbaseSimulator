//
//  PortfolioPieChartView.swift
//  CoinbaseSimulator
//
//  Created by vincent helvie on 5/19/25.
//

import SwiftUI
import Charts

struct PortfolioPieChartView: View {
    let viewModel: MarketViewModel

    struct PieSlice: Identifiable {
        let id = UUID()
        let symbol: String
        let valueUSD: Double
    }

    var body: some View {
        let slices = viewModel.assets.compactMap { asset -> PieSlice? in
            guard let qty = viewModel.portfolio.holdings[asset.symbol], qty > 0 else { return nil }
            return PieSlice(symbol: asset.symbol, valueUSD: qty * asset.price)
        }

        VStack {
            if slices.isEmpty {
                Text("No holdings to display.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                Chart(slices) { slice in
                    SectorMark(
                        angle: .value("USD Value", slice.valueUSD),
                        innerRadius: .ratio(0.5),
                        angularInset: 1.0
                    )
                    .foregroundStyle(by: .value("Symbol", slice.symbol))
                    .annotation(position: .overlay) {
                        Text(slice.symbol)
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
                .frame(height: 300)

                Text("Portfolio Distribution")
                    .font(.headline)
                    .padding(.top)
            }
        }
        .navigationTitle("Portfolio Chart")
        .padding()
    }
}
