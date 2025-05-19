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
        List(viewModel.trades.reversed()) { trade in
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(trade.isBuy ? "Bought" : "Sold")
                        .foregroundColor(trade.isBuy ? .green : .red)
                        .bold()
                    Text(trade.asset)
                        .fontWeight(.semibold)
                }

                Text("Quantity: \(String(format: "%.6f", trade.quantity)) @ $\(String(format: "%.2f", trade.price))")
                    .font(.subheadline)

                Text(trade.timestamp.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 6)
        }
        .navigationTitle("Trade History")
    }
}
