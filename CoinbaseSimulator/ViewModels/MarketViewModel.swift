//
//  MarketViewModel.swift
//  CoinbaseSimulator
//
//  Created by vincent helvie on 5/19/25.
//

import Foundation

class MarketViewModel: ObservableObject {
    @Published var assets: [Asset] = []
    private let api = CoinbaseAPI()

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
}
