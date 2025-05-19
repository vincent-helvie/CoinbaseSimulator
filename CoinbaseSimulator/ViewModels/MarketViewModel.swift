//
//  MarketViewModel.swift
//  CoinbaseSimulator
//
//  Created by vincent helvie on 5/19/25.
//

import Foundation

class MarketViewModel: ObservableObject {
    @Published var assets: [Asset] = []
    @Published var portfolio = Portfolio(balance: 10000.0, holdings: [:])
    @Published var trades: [Trade] = []

    private let api = CoinbaseAPI()

    // Persistence Keys
    private let tradesKey = "simulated_trades"
    private let portfolioKey = "simulated_portfolio"

    init() {
        loadData()
    }

    func loadPrices() {
        let symbols = ["BTC", "ETH", "SOL"]

        for symbol in symbols {
            api.fetchPrice(for: symbol) { [weak self] price in
                guard let self = self, let price = price else { return }

                DispatchQueue.main.async {
                    let asset = Asset(symbol: symbol, name: symbol, price: price)
                    if let index = self.assets.firstIndex(where: { $0.symbol == symbol }) {
                        self.assets[index] = asset
                    } else {
                        self.assets.append(asset)
                    }
                }
            }
        }
    }

    func buy(asset: Asset, amountUSD: Double) {
        let quantity = amountUSD / asset.price
        guard amountUSD <= portfolio.balance else { return }

        portfolio.balance -= amountUSD
        portfolio.holdings[asset.symbol, default: 0] += quantity

        let trade = Trade(
            asset: asset.symbol,
            isBuy: true,
            quantity: quantity,
            price: asset.price,
            timestamp: Date()
        )

        trades.append(trade)
        saveData()
    }

    func sell(asset: Asset, amountUSD: Double) {
        let quantity = amountUSD / asset.price
        let currentQty = portfolio.holdings[asset.symbol, default: 0]
        guard quantity <= currentQty else { return }

        portfolio.balance += amountUSD
        portfolio.holdings[asset.symbol] = currentQty - quantity

        let trade = Trade(
            asset: asset.symbol,
            isBuy: false,
            quantity: quantity,
            price: asset.price,
            timestamp: Date()
        )

        trades.append(trade)
        saveData()
    }

    func saveData() {
        if let encodedTrades = try? JSONEncoder().encode(trades) {
            UserDefaults.standard.set(encodedTrades, forKey: tradesKey)
        }

        if let encodedPortfolio = try? JSONEncoder().encode(portfolio) {
            UserDefaults.standard.set(encodedPortfolio, forKey: portfolioKey)
        }
    }

    func loadData() {
        if let savedTrades = UserDefaults.standard.data(forKey: tradesKey),
           let decodedTrades = try? JSONDecoder().decode([Trade].self, from: savedTrades) {
            self.trades = decodedTrades
        }

        if let savedPortfolio = UserDefaults.standard.data(forKey: portfolioKey),
           let decodedPortfolio = try? JSONDecoder().decode(Portfolio.self, from: savedPortfolio) {
            self.portfolio = decodedPortfolio
        }
    }
}
