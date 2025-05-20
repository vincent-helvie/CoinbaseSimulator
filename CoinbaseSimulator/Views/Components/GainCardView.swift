//
//  GainCardView.swift
//  CoinbaseSimulator
//
//  Created by vincent helvie on 5/20/25.
//

import SwiftUI

struct GainCardView: View {
    let title: String
    let percentage: Double?
    let ageDays: Int?

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            if let pct = percentage {
                Text(String(format: "%+.2f%%", pct))
                    .font(.headline)
                    .foregroundColor(pct >= 0 ? .green : .red)
            } else {
                Text("–")
                    .font(.headline)
                    .foregroundColor(.gray)
            }

            if let age = ageDays, age != 0 {
                Text("(~\(age)d)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 80, height: 70)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}
