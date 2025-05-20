import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MarketViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Text("Portfolio Value: $\(String(format: "%.2f", viewModel.portfolioValue))")
                    .font(.headline)
                    .padding(.top)

                Text("Cash Balance: $\(String(format: "%.2f", viewModel.portfolio.balance))")
                    .font(.subheadline)

                if viewModel.isLoading {
                    ProgressView("Fetching Prices...")
                        .padding()
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

                                if let holdingQty = viewModel.portfolio.holdings[asset.symbol], holdingQty > 0 {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("You own \(String(format: "%.6f", holdingQty)) \(asset.symbol)")
                                        Text("≈ $\(String(format: "%.2f", holdingQty * asset.price))")
                                    }
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                }

                                HStack {
                                    Button("Buy $100") {
                                        viewModel.buy(asset: asset, amountUSD: 100)
                                    }
                                    .buttonStyle(.borderedProminent)

                                    Button("Sell $100") {
                                        viewModel.sell(asset: asset, amountUSD: 100)
                                    }
                                    .buttonStyle(.bordered)

                                    Button("Buy Max") {
                                        viewModel.buyMax(asset: asset)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.blue)
                                    .disabled(viewModel.portfolio.balance <= 0)

                                    Button("Sell Max") {
                                        viewModel.sellMax(asset: asset)
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
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Crypto Simulator")
        }
    }

    func flashColor(for direction: Asset.PriceChangeDirection) -> Color {
        switch direction {
        case .up: return Color.green.opacity(0.3)
        case .down: return Color.red.opacity(0.3)
        case .none: return Color.clear
        }
    }
}
