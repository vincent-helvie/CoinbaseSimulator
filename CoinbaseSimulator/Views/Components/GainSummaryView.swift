//
//  GainSummaryView.swift
//  CoinbaseSimulator
//
//  Created by vincent helvie on 5/20/25.
//

import SwiftUI

struct GainSummaryView: View {
    let realized: Double
    let unrealized: Double

    @State private var expanded = false
    private var total: Double { realized + unrealized }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Gain/Loss: \(formatCurrency(total))")
                        .font(.subheadline)
                        .foregroundColor(total >= 0 ? .green : .red)

                    HStack(spacing: 12) {
                        Text("Realized: \(formatCurrency(realized))")
                            .font(.caption)
                            .foregroundColor(realized >= 0 ? .green : .red)

                        Text("Unrealized: \(formatCurrency(unrealized))")
                            .font(.caption)
                            .foregroundColor(unrealized >= 0 ? .green : .red)
                    }
                }

                Spacer()

                Image(systemName: expanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.gray)
                    .imageScale(.small)
            }
            .onTapGesture {
                withAnimation(.easeInOut) {
                    expanded.toggle()
                }
            }

            if expanded {
                Divider().padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Realized = Sell Proceeds − Buy Cost Basis")
                    Text("Unrealized = (Current Price − Avg Buy) × Quantity")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }

    private func formatCurrency(_ value: Double) -> String {
        String(format: "%@%.2f", value >= 0 ? "+" : "-", abs(value))
    }
}
