import SwiftUI

struct TradeHistoryView: View {
    @ObservedObject var viewModel: MarketViewModel

    var body: some View {
        List {
            if viewModel.trades.isEmpty {
                Text("No trades yet.")
                    .foregroundColor(.gray)
            } else {
                ForEach(viewModel.trades.sorted(by: { $0.timestamp > $1.timestamp })) { trade in
                    VStack(alignment: .leading, spacing: 6) {
                        // Top Row: Direction + Asset + Timestamp
                        HStack {
                            Label(trade.isBuy ? "Buy" : "Sell", systemImage: trade.isBuy ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                .foregroundColor(trade.isBuy ? .green : .red)
                                .fontWeight(.bold)

                            Text(trade.asset)
                                .font(.subheadline)

                            Spacer()

                            Text(trade.timestamp.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }

                        // Quantity and Price
                        HStack {
                            Text("Qty: \(String(format: "%.6f", trade.quantity))")
                            Text("Price: $\(String(format: "%.2f", trade.price))")
                        }
                        .font(.caption)

                        // Total USD value
                        Text("Total: $\(String(format: "%.2f", trade.quantity * trade.price))")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        // Optional gain/loss logic could go here
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle("Trade History")
    }
}
