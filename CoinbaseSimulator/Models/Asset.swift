import Foundation

struct Asset: Identifiable {
    let id = UUID()
    let symbol: String         // e.g. "BTC"
    let name: String           // e.g. "Bitcoin"
    let logoName: String?      // e.g. "bitcoin" (must match an image in Assets.xcassets)

    var price: Double
    var previousPrice: Double?
    var flashID = UUID()

    var chartData1h: [Double] = []
    var chartData24h: [Double] = []
    var chartData7d: [Double] = []
    var historicalPrices: [Double] = []

    var priceChangeDirection: PriceChangeDirection {
        guard let previous = previousPrice else { return .none }
        if price > previous { return .up }
        if price < previous { return .down }
        return .none
    }

    var percentChange: Double? {
        guard let previous = previousPrice, previous != 0 else { return nil }
        return ((price - previous) / previous) * 100
    }

    enum PriceChangeDirection {
        case up, down, none
    }
}
