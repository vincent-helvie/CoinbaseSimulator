import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MarketViewModel()

    struct TradeIntent: Identifiable {
        let id = UUID()
        let asset: Asset
        let type: TradeType
    }

    @State private var activeTrade: TradeIntent?
    @State private var selectedChartRange: [String: String] = [:]
    @State private var navigateToPortfolio = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 🔷 Header with Branding + Portfolio Info
                    HeaderView(
                        portfolioValue: viewModel.portfolioValue,
                        cashBalance: viewModel.portfolio.balance,
                        lastUpdated: viewModel.lastUpdated,
                        onPortfolioTap: {
                            navigateToPortfolio = true
                        }
                    )

                    // 📈 Asset List
                    ForEach(viewModel.assets) { asset in
                        assetRow(asset)
                            .padding(.horizontal)
                    }

                    NavigationLink(destination: PortfolioDetailView(viewModel: viewModel), isActive: $navigateToPortfolio) {
                        EmptyView()
                    }
                    .hidden()
                }
                .padding(.vertical)
            }
            .navigationBarHidden(true)
            .sheet(item: $activeTrade) { trade in
                TradeConfirmationSheet(viewModel: viewModel, asset: trade.asset, type: trade.type)
            }
        }
    }

    @ViewBuilder
    func assetRow(_ asset: Asset) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                if let logoURL = asset.logoURL {
                    RemoteImage(url: logoURL)
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                }

                VStack(alignment: .leading) {
                    Text(asset.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(asset.symbol)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(String(format: "$%.2f", asset.price))
                    if let change = asset.percentChange {
                        Text(String(format: "%@%.2f%%", change >= 0 ? "+" : "", change))
                            .font(.caption)
                            .foregroundColor(change >= 0 ? .green : .red)
                    }
                }
            }

            if let qty = viewModel.portfolio.holdings[asset.symbol], qty > 0 {
                VStack(alignment: .leading, spacing: 2) {
                    Text("You own \(String(format: "%.6f", qty)) \(asset.symbol)")
                    Text("≈ $\(String(format: "%.2f", qty * asset.price))")
                }
                .font(.footnote)
                .foregroundColor(.secondary)
            }

            Picker("", selection: Binding(
                get: { selectedChartRange[asset.symbol] ?? "24h" },
                set: { selectedChartRange[asset.symbol] = $0 }
            )) {
                Text("1h").tag("1h")
                Text("24h").tag("24h")
                Text("7d").tag("7d")
            }
            .pickerStyle(.segmented)
            .font(.caption)

            let (chartData, label) = chartData(for: asset)
            AssetChartView(prices: chartData, label: label)

            HStack {
                Button("Buy") {
                    activeTrade = TradeIntent(asset: asset, type: .buy)
                }
                .buttonStyle(.borderedProminent)

                Button("Sell") {
                    activeTrade = TradeIntent(asset: asset, type: .sell)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .padding(.vertical, 6)
    }

    func chartData(for asset: Asset) -> ([Double], String) {
        let range = selectedChartRange[asset.symbol] ?? "24h"
        switch range {
        case "1h": return (asset.chartData1h, "1h trend")
        case "7d": return (asset.chartData7d, "7d trend")
        default: return (asset.chartData24h, "24h trend")
        }
    }
}
