//
//  CoinbaseAPI.swift
//  CoinbaseSimulator
//
//  Created by vincent helvie on 5/19/25.
//

import Foundation

class CoinbaseAPI {
    func fetchPrice(for symbol: String, completion: @escaping (Double?) -> Void) {
        let urlString = "https://api.coinbase.com/v2/prices/\(symbol)-USD/spot"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let dataDict = json["data"] as? [String: Any],
                   let amountStr = dataDict["amount"] as? String,
                   let price = Double(amountStr) {
                    completion(price)
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }
}
