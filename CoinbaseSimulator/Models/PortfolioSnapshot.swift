//
//  PortfolioSnapshot.swift
//  CoinbaseSimulator
//
//  Created by vincent helvie on 5/20/25.
//

import Foundation

struct PortfolioSnapshot: Identifiable, Codable {
    let id = UUID()
    let timestamp: Date
    let value: Double
}
