import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MarketViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Text("Balance: $\(String(format: "%.2f", viewModel.portfolio.balance))")
                    .font(.title2)
                    .padding(.top)

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
                                    Text(String(format: "$%.2f", asset.price))
                                        .foregroundColor(.green)
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
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Crypto Simulator")
        }
    }
}
