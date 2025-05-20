import Foundation

class MarketViewModel: ObservableObject {
    @Published var assets: [Asset] = []
    @Published var portfolio = Portfolio(balance: 10000.0, holdings: [:])
    @Published var trades: [Trade] = []
    @Published var lastUpdated: Date?
    @Published var portfolioHistory: [PortfolioSnapshot] = []

    private let api = CoinbaseAPI()
    private let tradesKey = "simulated_trades"
    private let portfolioKey = "simulated_portfolio"
    private let historyKey = "portfolio_history"
    private var timer: Timer?

    init() {
        loadData()
        loadHistory()
        startPriceUpdates()
    }

    deinit {
        timer?.invalidate()
    }

    func startPriceUpdates() {
        loadPrices()
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { [weak self] _ in
            self?.loadPrices()
        }
    }

    func loadPrices() {
        let symbols = ["BTC", "ETH", "SOL", "ADA", "LTC", "AVAX", "DOGE"]

        let assetInfo: [String: (name: String, logoURL: String)] = [
            "BTC": ("Bitcoin", "https://assets.coingecko.com/coins/images/1/large/bitcoin.png"),
            "ETH": ("Ethereum", "https://assets.coingecko.com/coins/images/279/large/ethereum.png"),
            "SOL": ("Solana", "https://assets.coingecko.com/coins/images/4128/large/solana.png"),
            "ADA": ("Cardano", "https://assets.coingecko.com/coins/images/975/large/cardano.png"),
            "LTC": ("Litecoin", "https://assets.coingecko.com/coins/images/2/large/litecoin.png"),
            "AVAX": ("Avalanche", "https://assets.coingecko.com/coins/images/12559/large/Avalanche_Circle.png"),
            "DOGE": ("Dogecoin", "https://assets.coingecko.com/coins/images/5/large/dogecoin.png")
        ]

        let group = DispatchGroup()

        for (i, symbol) in symbols.enumerated() {
            group.enter()
            let delay = DispatchTime.now() + Double(i) * 0.5

            let workItem = DispatchWorkItem {
                self.api.fetchPrice(for: symbol) { [weak self] price in
                    guard let self = self else {
                        group.leave()
                        return
                    }

                    if let price = price {
                        let meta = assetInfo[symbol] ?? (symbol, nil)
                        self.fetchAndUpdateAsset(symbol: symbol, price: price, meta: meta, group: group)
                    } else {
                        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                            let meta = assetInfo[symbol] ?? (symbol, nil)
                            self.retryPriceLoad(symbol: symbol, meta: meta, group: group)
                        }
                    }
                }
            }

            DispatchQueue.main.asyncAfter(deadline: delay, execute: workItem)
        }

        group.notify(queue: .main) {
            self.lastUpdated = Date()
            let snapshot = PortfolioSnapshot(timestamp: Date(), value: self.portfolioValue)
            if self.shouldSaveNewSnapshot(snapshot) {
                self.portfolioHistory.append(snapshot)
                self.trimHistoryIfNeeded()
                self.saveHistory()
            }
        }
    }

    private func fetchAndUpdateAsset(symbol: String, price: Double, meta: (name: String, logoURL: String?), group: DispatchGroup) {
        self.api.fetchHistoricalPrices(symbol: symbol, interval: 300) { chart1h in
            self.api.fetchHistoricalPrices(symbol: symbol, interval: 3600) { chart24h in
                self.api.fetchHistoricalPrices(symbol: symbol, interval: 86400) { chart7d in
                    DispatchQueue.main.async {
                        if let index = self.assets.firstIndex(where: { $0.symbol == symbol }) {
                            var updated = self.assets[index]
                            updated.previousPrice = updated.price
                            updated.price = price
                            updated.flashID = UUID()
                            updated.chartData1h = chart1h
                            updated.chartData24h = chart24h
                            updated.chartData7d = chart7d
                            updated.historicalPrices = chart24h
                            self.assets[index] = updated
                        } else {
                            let newAsset = Asset(
                                symbol: symbol,
                                name: meta.name,
                                logoURL: meta.logoURL,
                                price: price,
                                previousPrice: nil,
                                flashID: UUID(),
                                chartData1h: chart1h,
                                chartData24h: chart24h,
                                chartData7d: chart7d,
                                historicalPrices: chart24h
                            )
                            self.assets.append(newAsset)
                        }
                        group.leave()
                    }
                }
            }
        }
    }

    func retryPriceLoad(symbol: String, meta: (name: String, logoURL: String?), group: DispatchGroup) {
        self.api.fetchPrice(for: symbol) { [weak self] retryPrice in
            guard let self = self else {
                group.leave()
                return
            }

            if let retryPrice = retryPrice {
                self.fetchAndUpdateAsset(symbol: symbol, price: retryPrice, meta: meta, group: group)
            } else {
                group.leave()
            }
        }
    }

    private func trimHistoryIfNeeded() {
        if portfolioHistory.count > 500 {
            portfolioHistory.removeFirst(portfolioHistory.count - 500)
        }
    }

    private func saveHistory() {
        if let data = try? JSONEncoder().encode(portfolioHistory) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }

    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([PortfolioSnapshot].self, from: data) {
            self.portfolioHistory = decoded
        }
    }

    func shouldSaveNewSnapshot(_ new: PortfolioSnapshot) -> Bool {
        guard let last = portfolioHistory.last else { return true }
        return !Calendar.current.isDate(last.timestamp, inSameDayAs: new.timestamp)
    }

    func buy(asset: Asset, amountUSD: Double) {
        let quantity = amountUSD / asset.price
        guard amountUSD <= portfolio.balance else { return }

        portfolio.balance -= amountUSD
        portfolio.holdings[asset.symbol, default: 0] += quantity

        trades.append(Trade(asset: asset.symbol, isBuy: true, quantity: quantity, price: asset.price, timestamp: Date()))
        saveData()
    }

    func buyMax(asset: Asset) {
        buy(asset: asset, amountUSD: portfolio.balance)
    }

    func sell(asset: Asset, amountUSD: Double) {
        let quantity = amountUSD / asset.price
        let currentQty = portfolio.holdings[asset.symbol, default: 0]
        guard quantity <= currentQty else { return }

        portfolio.balance += amountUSD
        portfolio.holdings[asset.symbol] = currentQty - quantity

        trades.append(Trade(asset: asset.symbol, isBuy: false, quantity: quantity, price: asset.price, timestamp: Date()))
        saveData()
    }

    func sellMax(asset: Asset) {
        let quantity = portfolio.holdings[asset.symbol] ?? 0
        guard quantity > 0 else { return }
        sell(asset: asset, amountUSD: quantity * asset.price)
    }

    var portfolioValue: Double {
        assets.reduce(0.0) { total, asset in
            let qty = portfolio.holdings[asset.symbol] ?? 0
            return total + (qty * asset.price)
        }
    }

    func averageBuyPrice(for symbol: String) -> Double? {
        let buys = trades.filter { $0.asset == symbol && $0.isBuy }
        let totalSpent = buys.reduce(0.0) { $0 + ($1.price * $1.quantity) }
        let totalQty = buys.reduce(0.0) { $0 + $1.quantity }
        return totalQty > 0 ? totalSpent / totalQty : nil
    }

    func realizedGainLoss(for symbol: String? = nil) -> Double {
        var gainLoss: Double = 0.0
        let filteredTrades = symbol == nil ? trades : trades.filter { $0.asset == symbol }

        var buyQueue: [String: [(quantity: Double, price: Double)]] = [:]

        for trade in filteredTrades {
            if trade.isBuy {
                buyQueue[trade.asset, default: []].append((quantity: trade.quantity, price: trade.price))
            } else {
                var remaining = trade.quantity
                var costBasis = 0.0

                var queue = buyQueue[trade.asset] ?? []
                var newQueue: [(quantity: Double, price: Double)] = []

                for (qty, price) in queue {
                    if remaining <= 0 {
                        newQueue.append((qty, price))
                        continue
                    }

                    let usedQty = min(qty, remaining)
                    costBasis += usedQty * price
                    remaining -= usedQty

                    let leftoverQty = qty - usedQty
                    if leftoverQty > 0 {
                        newQueue.append((leftoverQty, price))
                    }
                }

                buyQueue[trade.asset] = newQueue
                let proceeds = trade.quantity * trade.price
                gainLoss += proceeds - costBasis
            }
        }

        return gainLoss
    }

    func unrealizedGainLoss(for symbol: String? = nil) -> Double {
        var total: Double = 0.0

        let relevantAssets = symbol != nil
            ? assets.filter { $0.symbol == symbol }
            : assets

        for asset in relevantAssets {
            let quantity = portfolio.holdings[asset.symbol] ?? 0
            guard quantity > 0 else { continue }

            guard let avgPrice = averageBuyPrice(for: asset.symbol) else { continue }

            let gainLoss = (asset.price - avgPrice) * quantity
            total += gainLoss
        }

        return total
    }

    func gainPercentWithAge(since daysAgo: Int) -> (percent: Double, ageDays: Int)? {
        guard !portfolioHistory.isEmpty else { return nil }

        let targetDate = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date())!

        // Find the snapshot closest to targetDate
        let snapshot = portfolioHistory
            .filter { $0.timestamp < Date() }
            .min(by: { abs($0.timestamp.timeIntervalSince(targetDate)) < abs($1.timestamp.timeIntervalSince(targetDate)) })

        guard let past = snapshot else { return nil }

        let current = portfolioValue
        let change = current - past.value
        let percentChange = (change / past.value) * 100
        let ageDays = Calendar.current.dateComponents([.day], from: past.timestamp, to: Date()).day ?? 0

        return (percentChange, ageDays)
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
