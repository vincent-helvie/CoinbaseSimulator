//
//  Portfolio.swift
//  CoinbaseSimulator
//
//  Created by vincent helvie on 5/19/25.
//

import Foundation

struct Portfolio: Codable {
    var balance: Double
    var holdings: [String: Double]
}
