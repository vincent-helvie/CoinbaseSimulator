import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MarketViewModel()
    @State private var now = Date()

    enum TradeAction { case buyMax, sellMax, buy100, sell100 }
    @State private var selectedAsset: Asset?
    @State private var selectedAction: TradeAction?
    @State private var selectedChartRange: [String: String] = [:]

    var body: some View {
        NavigationView {
            VStack {
                Text("Portfolio Value: $\(String(format: "%.2f", viewModel.portfolioValue))")
                    .font(.headline)
                    .padding(.top)

                Text("Cash Balance: $\(String(format: "%.2f", viewModel.portfolio.balance))")
                    .font(.subheadline)

                if let updated = viewModel.lastUpdated {
                    Text("Last updated \(relativeTime(from: updated))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                List {
                    Section(header: Text("Assets")) {
                        ForEach(viewModel.assets) { asset in
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(asset.symbol)
                                        .fontWeight(.bold)

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
                                .padding()
                                .background(
                                    flashColor(for: asset.priceChangeDirection)
                                        .opacity(0.6)
                                        .animation(.easeOut(duration: 0.7), value: asset.flashID)
                                )
                                .cornerRadius(8)

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
                                .padding(.vertical, 2)

                                let (chartData, label) = chartData(for: asset)

                                AssetChartView(prices: chartData, label: label)
                                    .padding(.top, 4)

                                HStack {
                                    Button("Buy $100") {
                                        selectedAsset = asset
                                        selectedAction = .buy100
                                    }
                                    .buttonStyle(.borderedProminent)

                                    Button("Sell $100") {
                                        selectedAsset = asset
                                        selectedAction = .sell100
                                    }
                                    .buttonStyle(.bordered)

                                    Button("Buy Max") {
                                        selectedAsset = asset
                                        selectedAction = .buyMax
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.blue)
                                    .disabled(viewModel.portfolio.balance <= 0)

                                    Button("Sell Max") {
                                        selectedAsset = asset
                                        selectedAction = .sellMax
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.red)
                                    .disabled((viewModel.portfolio.holdings[asset.symbol] ?? 0) <= 0)
                                }
                                .padding(.top, 5)
                            }
                            .padding(.vertical, 6)
                        }
                    }

                    Section {
                        NavigationLink("View Trade History") {
                            TradeHistoryView(viewModel: viewModel)
                        }
                        NavigationLink("View Portfolio Chart") {
                            PortfolioPieChartView(viewModel: viewModel)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Crypto Simulator")
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    now = Date()
                }
            }
            .alert("Confirm Trade", isPresented: Binding(
                get: { selectedAsset != nil && selectedAction != nil },
                set: { if !$0 { selectedAsset = nil; selectedAction = nil } }
            ), presenting: selectedAsset) { asset in
                Button("Confirm", role: .destructive) {
                    handleTrade(asset: asset)
                }
                Button("Cancel", role: .cancel) { }
            } message: { asset in
                switch selectedAction {
                case .buyMax:
                    Text("Buy max \(asset.symbol) for $\(String(format: "%.2f", viewModel.portfolio.balance))?")
                case .sellMax:
                    let qty = viewModel.portfolio.holdings[asset.symbol] ?? 0
                    Text("Sell all \(String(format: "%.6f", qty)) \(asset.symbol)?")
                case .buy100:
                    Text("Buy $100 of \(asset.symbol)?")
                case .sell100:
                    Text("Sell $100 of \(asset.symbol)?")
                case .none:
                    Text("Invalid action.")
                }
            }
        }
    }

    // MARK: - Helpers

    func chartData(for asset: Asset) -> ([Double], String) {
        let range = selectedChartRange[asset.symbol] ?? "24h"
        switch range {
        case "1h": return (asset.chartData1h, "1h trend")
        case "7d": return (asset.chartData7d, "7d trend")
        default: return (asset.chartData24h, "24h trend")
        }
    }

    func handleTrade(asset: Asset) {
        guard let action = selectedAction else { return }
        switch action {
        case .buyMax: viewModel.buyMax(asset: asset)
        case .sellMax: viewModel.sellMax(asset: asset)
        case .buy100: viewModel.buy(asset: asset, amountUSD: 100)
        case .sell100: viewModel.sell(asset: asset, amountUSD: 100)
        }
    }

    func flashColor(for direction: Asset.PriceChangeDirection) -> Color {
        switch direction {
        case .up: return .green.opacity(0.3)
        case .down: return .red.opacity(0.3)
        case .none: return .clear
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
