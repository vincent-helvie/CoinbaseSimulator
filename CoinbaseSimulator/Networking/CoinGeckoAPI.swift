//
//  CoinGeckoAPI.swift
//  CoinbaseSimulator
//
//  Created by vincent helvie on 5/20/25.
//

import Foundation

struct CoinGeckoCoin: Decodable {
    let id: String
    let symbol: String
    let name: String
    let image: String
    let current_price: Double
    let price_change_percentage_24h: Double?
}

class CoinGeckoAPI {
    func fetchTopCoins(completion: @escaping ([CoinGeckoCoin]) -> Void) {
        let urlString = "https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=50&page=1"
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion([])
                return
            }

            if let coins = try? JSONDecoder().decode([CoinGeckoCoin].self, from: data) {
                completion(coins)
            } else {
                completion([])
            }
        }.resume()
    }
}
