//
//  Trade.swift
//  CoinbaseSimulator
//
//  Created by vincent helvie on 5/19/25.
//

import Foundation

struct Trade: Identifiable, Codable {
    let id: UUID
    let asset: String
    let isBuy: Bool
    let quantity: Double
    let price: Double
    let timestamp: Date

    init(asset: String, isBuy: Bool, quantity: Double, price: Double, timestamp: Date) {
        self.id = UUID()
        self.asset = asset
        self.isBuy = isBuy
        self.quantity = quantity
        self.price = price
        self.timestamp = timestamp
    }
}
