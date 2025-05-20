import SwiftUI

struct PortfolioDetailView: View {
    @ObservedObject var viewModel: MarketViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 💼 Portfolio Summary
                VStack(alignment: .leading, spacing: 8) {
                    Text("Portfolio Value")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("$\(String(format: "%.2f", viewModel.portfolioValue))")
                        .font(.title2)
                        .bold()

                    Text("Cash: $\(String(format: "%.2f", viewModel.portfolio.balance))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)

                // 📈 Gain Cards
                HStack(spacing: 12) {
                    let oneDay = viewModel.gainPercentWithAge(since: 1)
                    let sevenDay = viewModel.gainPercentWithAge(since: 7)
                    let thirtyDay = viewModel.gainPercentWithAge(since: 30)

                    GainCardView(title: "1D", percentage: oneDay?.percent, ageDays: oneDay?.ageDays)
                    GainCardView(title: "7D", percentage: sevenDay?.percent, ageDays: sevenDay?.ageDays)
                    GainCardView(title: "30D", percentage: thirtyDay?.percent, ageDays: thirtyDay?.ageDays)
                }
                .padding(.horizontal)

                // 📉 Portfolio Chart
                PortfolioChartView(snapshots: viewModel.portfolioHistory)

                // 🔗 Trade History Link
                VStack(alignment: .leading, spacing: 4) {
                    NavigationLink("View Trade History") {
                        TradeHistoryView(viewModel: viewModel)
                    }
                    .padding(.horizontal)
                }

                // 📋 Holdings List
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Holdings")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(viewModel.assets.filter { (viewModel.portfolio.holdings[$0.symbol] ?? 0) > 0 }) { asset in
                        let qty = viewModel.portfolio.holdings[asset.symbol] ?? 0
                        let avgPrice = viewModel.averageBuyPrice(for: asset.symbol)

                        HoldingCard(
                            asset: asset,
                            quantity: qty,
                            totalValue: viewModel.portfolioValue,
                            avgBuyPrice: avgPrice
                        )
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.top)
        }
        .navigationTitle("Portfolio")
    }
}
