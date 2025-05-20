//
//  TradeHistoryView.swift
//  CoinbaseSimulator
//
//  Created by vincent helvie on 5/19/25.
//

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
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(trade.isBuy ? "Buy" : "Sell")
                                .fontWeight(.bold)
                                .foregroundColor(trade.isBuy ? .green : .red)
                            Text(trade.asset)
                                .font(.subheadline)
                            Spacer()
                            Text(String(format: "$%.2f", trade.price))
                                .font(.subheadline)
                        }

                        Text(String(format: "%.6f %@", trade.quantity, trade.asset))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(trade.timestamp.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Trade History")
    }
}
