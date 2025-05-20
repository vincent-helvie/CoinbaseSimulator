import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MarketViewModel()
    @State private var now = Date()

    struct TradeIntent: Identifiable {
        let id = UUID()
        let asset: Asset
        let type: TradeType
    }

    @State private var activeTrade: TradeIntent?
    @State private var selectedChartRange: [String: String] = [:]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    // Portfolio summary
                    VStack {
                        Text("Portfolio Value: $\(String(format: "%.2f", viewModel.portfolioValue))")
                            .font(.title3)
                            .bold()
                        Text("Cash Balance: $\(String(format: "%.2f", viewModel.portfolio.balance))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        if let updated = viewModel.lastUpdated {
                            Text("Last updated \(relativeTime(from: updated))")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        NavigationLink("View Portfolio Detail") {
                            PortfolioDetailView(viewModel: viewModel)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal)

                    ForEach(viewModel.assets) { asset in
                        assetRow(asset)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Crypto Simulator")
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    now = Date()
                }
            }
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
                        Text(String(format: "%@%.2f%%",
                                    change >= 0 ? "+" : "",
                                    change))
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

    func relativeTime(from date: Date) -> String {
        let seconds = Int(now.timeIntervalSince(date))
        if seconds < 5 {
            return "just now"
        } else if seconds < 60 {
            return "\(seconds) seconds ago"
        } else {
            let minutes = seconds / 60
            return "\(minutes) minute\(minutes > 1 ? "s" : "") ago"
        }
    }
}
