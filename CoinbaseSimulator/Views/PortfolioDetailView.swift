import SwiftUI

struct PortfolioDetailView: View {
    @ObservedObject var viewModel: MarketViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    SummaryCard(title: "Total Value", value: "$\(String(format: "%.2f", viewModel.portfolioValue))")
                    SummaryCard(title: "Cash", value: "$\(String(format: "%.2f", viewModel.portfolio.balance))")
                }
                .padding(.horizontal)

                PortfolioChartView(snapshots: viewModel.portfolioHistory)

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
