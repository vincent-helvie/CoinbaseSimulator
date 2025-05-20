import SwiftUI

struct HoldingCard: View {
    let asset: Asset
    let quantity: Double
    let totalValue: Double
    let avgBuyPrice: Double?

    var body: some View {
        let currentValue = quantity * asset.price
        let percentOfPortfolio = totalValue > 0 ? currentValue / totalValue * 100 : 0

        let gainLossAmount: Double? = {
            guard let avg = avgBuyPrice else { return nil }
            return (asset.price - avg) * quantity
        }()

        let gainLossPercent: Double? = {
            guard let avg = avgBuyPrice, avg != 0 else { return nil }
            return (asset.price - avg) / avg * 100
        }()

        return HStack(spacing: 12) {
            if let logoURL = asset.logoURL {
                RemoteImage(url: logoURL)
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(asset.name)
                    .font(.subheadline)
                    .bold()
                Text(asset.symbol)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(String(format: "%.4f", quantity)) \(asset.symbol)")
                    .font(.caption2)
                Text(String(format: "%.1f%% of portfolio", percentOfPortfolio))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "$%.2f", currentValue))
                    .fontWeight(.medium)

                if let gain = gainLossAmount, let percent = gainLossPercent {
                    Text(String(format: "%@%.2f (%@%.1f%%)",
                                gain >= 0 ? "+" : "", gain,
                                gain >= 0 ? "+" : "", percent))
                    .font(.caption2)
                    .foregroundColor(gain >= 0 ? .green : .red)
                } else {
                    Text("–")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
}
