//
//  PortfolioDetailView.swift
//  CoinbaseSimulator
//
//  Created by vincent helvie on 5/20/25.
//

import SwiftUI

struct PortfolioDetailView: View {
    @ObservedObject var viewModel: MarketViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 🔹 Summary Cards
                HStack(spacing: 12) {
                    SummaryCard(title: "Total Value", value: "$\(String(format: "%.2f", viewModel.portfolioValue))")
                    SummaryCard(title: "Cash", value: "$\(String(format: "%.2f", viewModel.portfolio.balance))")
                }

                // 🔹 Portfolio Chart
                PortfolioChartView(snapshots: viewModel.portfolioHistory)

                // 🔹 Holdings Breakdown
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Holdings")
                        .font(.headline)
                        .padding(.leading, 8)

                    ForEach(viewModel.assets.filter { (viewModel.portfolio.holdings[$0.symbol] ?? 0) > 0 }) { asset in
                        HoldingCard(asset: asset, quantity: viewModel.portfolio.holdings[asset.symbol] ?? 0, totalValue: viewModel.portfolioValue)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .navigationTitle("Portfolio")
    }
}
