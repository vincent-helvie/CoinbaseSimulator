//
//  HoldingCard.swift
//  CoinbaseSimulator
//
//  Created by vincent helvie on 5/20/25.
//

import SwiftUI

struct HoldingCard: View {
    let asset: Asset
    let quantity: Double
    let totalValue: Double

    var body: some View {
        HStack(spacing: 12) {
            if let logoURL = asset.logoURL {
                RemoteImage(url: logoURL)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }

            VStack(alignment: .leading) {
                Text(asset.name)
                    .font(.subheadline)
                    .bold()
                Text(asset.symbol)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(String(format: "$%.2f", quantity * asset.price))
                    .fontWeight(.medium)
                Text("\(String(format: "%.4f", quantity)) \(asset.symbol)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                let percent = totalValue > 0 ? (quantity * asset.price) / totalValue * 100 : 0
                Text(String(format: "%.1f%% of portfolio", percent))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}
