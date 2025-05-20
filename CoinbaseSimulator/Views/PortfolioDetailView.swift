import SwiftUI

struct PortfolioDetailView: View {
    @ObservedObject var viewModel: MarketViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 💼 Summary Cards
                HStack(spacing: 12) {
                    SummaryCard(title: "Total Value", value: "$\(String(format: "%.2f", viewModel.portfolioValue))")
                    SummaryCard(title: "Cash", value: "$\(String(format: "%.2f", viewModel.portfolio.balance))")
                }
                .padding(.horizontal)

                // 📈 Realized Gains
                SummaryCard(
                    title: "Realized P/L",
                    value: String(format: "%@%.2f",
                                  viewModel.realizedGainLoss() >= 0 ? "+" : "",
                                  viewModel.realizedGainLoss())
                )
                .foregroundColor(viewModel.realizedGainLoss() >= 0 ? .green : .red)
                .padding(.horizontal)

                // 📊 Unrealized Gains
                SummaryCard(
                    title: "Unrealized P/L",
                    value: String(format: "%@%.2f",
                                  viewModel.unrealizedGainLoss() >= 0 ? "+" : "",
                                  viewModel.unrealizedGainLoss())
                )
                .foregroundColor(viewModel.unrealizedGainLoss() >= 0 ? .green : .red)
                .padding(.horizontal)

                // 📉 Portfolio chart
                PortfolioChartView(snapshots: viewModel.portfolioHistory)

                // 🔍 Holdings
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Holdings")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(viewModel.assets.filter { (viewModel.portfolio.holdings[$0.symbol] ?? 0) > 0 }) { asset in
                        let quantity = viewModel.portfolio.holdings[asset.symbol] ?? 0
                        let avgBuyPrice = viewModel.averageBuyPrice(for: asset.symbol)

                        HoldingCard(
                            asset: asset,
                            quantity: quantity,
                            totalValue: viewModel.portfolioValue,
                            avgBuyPrice: avgBuyPrice
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
            .padding(.top)
        }
        .navigationTitle("Portfolio")
    }
}
