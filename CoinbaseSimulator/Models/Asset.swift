//
//  Asset.swift
//  CoinbaseSimulator
//
//  Created by vincent helvie on 5/19/25.
//

import Foundation

struct Asset: Identifiable, Codable {
    let id = UUID()
    let symbol: String
    let name: String
    let price: Double
}
