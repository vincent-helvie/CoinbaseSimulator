import SwiftUI
import Charts

struct PortfolioChartView: View {
    let snapshots: [PortfolioSnapshot]

    @State private var selectedTimeframe: String = "24h"
    @State private var highlightedSnapshot: PortfolioSnapshot?

    private var filteredSnapshots: [PortfolioSnapshot] {
        guard let latest = snapshots.last else { return [] }

        let cutoff: Date? = {
            switch selectedTimeframe {
            case "1h": return Calendar.current.date(byAdding: .hour, value: -1, to: latest.timestamp)
            case "24h": return Calendar.current.date(byAdding: .hour, value: -24, to: latest.timestamp)
            case "7d": return Calendar.current.date(byAdding: .day, value: -7, to: latest.timestamp)
            default: return nil
            }
        }()

        return cutoff == nil ? snapshots : snapshots.filter { $0.timestamp >= cutoff! }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Portfolio Value Over Time")
                .font(.headline)

            Picker("Timeframe", selection: $selectedTimeframe) {
                Text("1h").tag("1h")
                Text("24h").tag("24h")
                Text("7d").tag("7d")
                Text("All").tag("All")
            }
            .pickerStyle(.segmented)
            .padding(.bottom, 4)

            if filteredSnapshots.count >= 2 {
                Chart {
                    // Line for portfolio value
                    ForEach(filteredSnapshots) { snapshot in
                        LineMark(
                            x: .value("Time", snapshot.timestamp),
                            y: .value("Value", snapshot.value)
                        )
                        .interpolationMethod(.catmullRom)
                    }

                    // Highlight selected point, if any
                    if let highlighted = highlightedSnapshot {
                        PointMark(
                            x: .value("Time", highlighted.timestamp),
                            y: .value("Value", highlighted.value)
                        )
                        .foregroundStyle(.blue)
                        .symbolSize(100)
                        .annotation(position: .top, alignment: .center) {
                            Text("$\(String(format: "%.2f", highlighted.value))")
                                .font(.caption)
                                .padding(4)
                                .background(Color(.systemBackground))
                                .cornerRadius(6)
                                .shadow(radius: 2)
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle().fill(Color.clear).contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        let location = value.location
                                        if let date: Date = proxy.value(atX: location.x),
                                           let closest = filteredSnapshots.min(by: {
                                               abs($0.timestamp.timeIntervalSince(date)) <
                                               abs($1.timestamp.timeIntervalSince(date))
                                           }) {
                                            highlightedSnapshot = closest
                                        }
                                    }
                                    .onEnded { _ in
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                            highlightedSnapshot = nil
                                        }
                                    }
                            )
                    }
                }
                .frame(height: 220)
                .animation(.easeInOut(duration: 0.3), value: selectedTimeframe)
            } else {
                Text("Not enough data yet to display chart.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            if let snapshot = highlightedSnapshot {
                Text("💰 $\(String(format: "%.2f", snapshot.value)) @ \(formatted(snapshot.timestamp))")
                    .font(.caption)
                    .padding(.top, 4)
            }
        }
        .padding()
    }

    func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = selectedTimeframe == "7d" ? .short : .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
