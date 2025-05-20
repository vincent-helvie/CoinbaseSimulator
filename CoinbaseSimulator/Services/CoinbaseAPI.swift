import Foundation

class CoinbaseAPI {
    func fetchPrice(for symbol: String, completion: @escaping (Double?) -> Void) {
        let url = URL(string: "https://api.coinbase.com/v2/prices/\(symbol)-USD/spot")!
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let dataDict = json["data"] as? [String: Any],
                  let amountString = dataDict["amount"] as? String,
                  let amount = Double(amountString) else {
                completion(nil)
                return
            }
            completion(amount)
        }.resume()
    }

    func fetchHistoricalPrices(symbol: String, interval: Int, completion: @escaping ([Double]) -> Void) {
        let productID = "\(symbol)-USD"
        let url = URL(string: "https://api.exchange.coinbase.com/products/\(productID)/candles?granularity=\(interval)")!

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [[Any]] else {
                completion([])
                return
            }

            let closes = json
                .sorted { ($0[0] as? Double ?? 0) < ($1[0] as? Double ?? 0) }
                .compactMap { $0[4] as? Double }

            completion(closes)
        }.resume()
    }
}
