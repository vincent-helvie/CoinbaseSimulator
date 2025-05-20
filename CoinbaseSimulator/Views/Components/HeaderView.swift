//
//  HeaderView.swift
//  CoinbaseSimulator
//
//  Created by vincent helvie on 5/20/25.
//

import SwiftUI

struct HeaderView: View {
    let portfolioValue: Double
    let cashBalance: Double
    let lastUpdated: Date?
    let onPortfolioTap: () -> Void

    @State private var now = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 🔷 App Branding
            HStack(spacing: 12) {
                Image(systemName: "bitcoinsign.circle.fill")
                    .foregroundColor(.orange)
                    .font(.title)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Crypto Simulator")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Track • Trade • Simulate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }

            // 💼 Portfolio Summary
            VStack(alignment: .leading, spacing: 4) {
                Text("Portfolio Value")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("$\(String(format: "%.2f", portfolioValue))")
                    .font(.title3)
                    .fontWeight(.semibold)

                Text("Cash Balance: $\(String(format: "%.2f", cashBalance))")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                if let updated = lastUpdated {
                    Text("Last updated \(relativeTime(from: updated))")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }

                Button("View Portfolio Detail", action: onPortfolioTap)
                    .font(.caption)
                    .padding(.top, 6)
            }
        }
        .padding(.horizontal)
        .padding(.top)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                now = Date()
            }
        }
    }

    private func relativeTime(from date: Date) -> String {
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
