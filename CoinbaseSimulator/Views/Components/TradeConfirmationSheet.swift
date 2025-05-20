//
//  TradeConfirmationSheet.swift
//  CoinbaseSimulator
//
//  Created by vincent helvie on 5/20/25.
//

import SwiftUI

enum TradeType {
    case buy, sell
}

struct TradeConfirmationSheet: View {
    @Environment(\.dismiss) var dismiss

    @ObservedObject var viewModel: MarketViewModel
    let asset: Asset
    let type: TradeType

    @State private var amountUSD: String = "100"
    @State private var showInvalidAmountAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 🔹 Asset Info
                HStack(spacing: 12) {
                    if let logo = asset.logoURL {
                        RemoteImage(url: logo)
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    }
                    VStack(alignment: .leading) {
                        Text(asset.name).font(.headline)
                        Text(asset.symbol).font(.caption).foregroundColor(.gray)
                    }
                    Spacer()
                    Text(String(format: "$%.2f", asset.price))
                        .font(.headline)
                }

                Divider()

                // 🔹 Amount Input
                VStack(alignment: .leading, spacing: 10) {
                    Text("Amount in USD")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextField("Enter amount", text: $amountUSD)
                        .keyboardType(.decimalPad)
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)

                    HStack {
                        ForEach([50, 100, 250], id: \.self) { amt in
                            Button("$\(amt)") {
                                amountUSD = "\(amt)"
                            }
                            .buttonStyle(.bordered)
                        }

                        Button("Max") {
                            if type == .buy {
                                amountUSD = String(format: "%.2f", viewModel.portfolio.balance)
                            } else {
                                let qty = viewModel.portfolio.holdings[asset.symbol] ?? 0
                                let maxSellUSD = qty * asset.price
                                amountUSD = String(format: "%.2f", maxSellUSD)
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                    }
                }

                // 🔹 Quantity preview
                if let usd = Double(amountUSD), usd > 0 {
                    let quantity = usd / asset.price
                    Text("\(type == .buy ? "Buy" : "Sell") approx. \(String(format: "%.6f", quantity)) \(asset.symbol)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Spacer()

                // 🔹 Confirm Button
                Button {
                    guard let usd = Double(amountUSD), usd > 0 else {
                        showInvalidAmountAlert = true
                        return
                    }

                    if type == .buy {
                        viewModel.buy(asset: asset, amountUSD: usd)
                    } else {
                        viewModel.sell(asset: asset, amountUSD: usd)
                    }

                    dismiss()
                } label: {
                    Text(type == .buy ? "Confirm Buy" : "Confirm Sell")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(type == .buy ? Color.green : Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.bottom)
            }
            .padding()
            .navigationTitle(type == .buy ? "Buy \(asset.symbol)" : "Sell \(asset.symbol)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Invalid Amount", isPresented: $showInvalidAmountAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}
