//
//  Asset.swift
//  CoinbaseSimulator
//
//  Created by vincent helvie on 5/19/25.
//

import Foundation

struct Asset: Identifiable {
    let id = UUID()
    let symbol: String
    let name: String
    var price: Double
    var previousPrice: Double?

    var priceChangeDirection: PriceChangeDirection {
        guard let previous = previousPrice else { return .none }
        if price > previous { return .up }
        if price < previous { return .down }
        return .none
    }

    enum PriceChangeDirection {
        case up, down, none
    }
}
