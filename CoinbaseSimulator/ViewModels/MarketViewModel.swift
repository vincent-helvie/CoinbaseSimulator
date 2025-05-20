import Foundation

class MarketViewModel: ObservableObject {
    @Published var assets: [Asset] = []
    @Published var portfolio = Portfolio(balance: 10000.0, holdings: [:])
    @Published var trades: [Trade] = []
    @Published var lastUpdated: Date?
    @Published var isLoadingCharts: Bool = false

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
        let assetNameMap: [String: (name: String, logo: String)] = [
            "BTC": ("Bitcoin", "bitcoin"),
            "ETH": ("Ethereum", "ethereum"),
            "SOL": ("Solana", "solana")
        ]

        DispatchQueue.main.async {
            self.isLoadingCharts = true
        }

        let group = DispatchGroup()

        for (i, symbol) in symbols.enumerated() {
            group.enter()

            let delay = DispatchTime.now() + Double(i) * 0.5
            let workItem = DispatchWorkItem {
                self.api.fetchPrice(for: symbol) { [weak self] price in
                    guard let self = self, let price = price else {
                        group.leave()
                        return
                    }

                    self.api.fetchHistoricalPrices(symbol: symbol, interval: 300) { chart1h in
                        self.api.fetchHistoricalPrices(symbol: symbol, interval: 3600) { chart24h in
                            self.api.fetchHistoricalPrices(symbol: symbol, interval: 86400) { chart7d in
                                let updateWork = DispatchWorkItem {
                                    let assetMeta = assetNameMap[symbol] ?? (name: symbol, logo: nil)

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
                                            name: assetMeta.name,
                                            logoName: assetMeta.logo,
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

                                DispatchQueue.main.asyncAfter(deadline: .now(), execute: updateWork)
                            }
                        }
                    }
                }
            }

            DispatchQueue.main.asyncAfter(deadline: delay, execute: workItem)
        }

        // ✅ Final group completion — using a closure
        group.notify(queue: .main) {
            self.lastUpdated = Date()
            self.isLoadingCharts = false
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
