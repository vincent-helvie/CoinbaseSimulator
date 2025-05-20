import Foundation

class MarketViewModel: ObservableObject {
    @Published var assets: [Asset] = []
    @Published var portfolio = Portfolio(balance: 10000.0, holdings: [:])
    @Published var trades: [Trade] = []
    @Published var lastUpdated: Date?

    private let api = CoinbaseAPI()
    private let tradesKey = "simulated_trades"
    private let portfolioKey = "simulated_portfolio"
    private var timer: Timer?

    init() {
        loadData()
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
        let symbols = ["BTC", "ETH", "SOL"]
        let group = DispatchGroup()

        for symbol in symbols {
            group.enter()
            api.fetchPrice(for: symbol) { [weak self] price in
                defer { group.leave() }

                guard let self = self, let price = price else { return }

                DispatchQueue.main.async {
                    if let index = self.assets.firstIndex(where: { $0.symbol == symbol }) {
                        var updatedAsset = self.assets[index]
                        updatedAsset.previousPrice = updatedAsset.price
                        updatedAsset.price = price
                        updatedAsset.flashID = UUID()

                        updatedAsset.chartData1h = (0..<12).map { _ in price * (0.99 + Double.random(in: 0...0.02)) }
                        updatedAsset.chartData24h = (0..<24).map { _ in price * (0.98 + Double.random(in: 0...0.04)) }
                        updatedAsset.chartData7d = (0..<7).map { _ in price * (0.95 + Double.random(in: 0...0.1)) }
                        updatedAsset.historicalPrices = updatedAsset.chartData24h

                        self.assets[index] = updatedAsset
                    } else {
                        let chart1h = (0..<12).map { _ in price * (0.99 + Double.random(in: 0...0.02)) }
                        let chart24h = (0..<24).map { _ in price * (0.98 + Double.random(in: 0...0.04)) }
                        let chart7d = (0..<7).map { _ in price * (0.95 + Double.random(in: 0...0.1)) }

                        let newAsset = Asset(
                            symbol: symbol,
                            name: symbol,
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
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.lastUpdated = Date()
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

    func buyMax(asset: Asset) {
        buy(asset: asset, amountUSD: portfolio.balance)
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

    func sellMax(asset: Asset) {
        let quantity = portfolio.holdings[asset.symbol] ?? 0
        guard quantity > 0 else { return }
        let amountUSD = quantity * asset.price
        sell(asset: asset, amountUSD: amountUSD)
    }

    var portfolioValue: Double {
        assets.reduce(0.0) { total, asset in
            let qty = portfolio.holdings[asset.symbol] ?? 0
            return total + (qty * asset.price)
        }
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
