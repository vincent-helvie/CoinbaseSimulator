import SwiftUI
import Charts

struct AssetChartView: View {
    let prices: [Double]
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            Chart {
                ForEach(prices.indices, id: \.self) { index in
                    LineMark(
                        x: .value("Index", index),
                        y: .value("Price", prices[index])
                    )
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 80)
        }
    }
}
