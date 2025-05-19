//
//  ContentView.swift
//  CoinbaseSimulator
//
//  Created by vincent helvie on 5/19/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MarketViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.assets) { asset in
                HStack {
                    Text(asset.symbol)
                        .fontWeight(.bold)
                    Spacer()
                    Text(String(format: "$%.2f", asset.price))
                        .foregroundColor(.green)
                }
            }
            .navigationTitle("Crypto Prices")
            .onAppear {
                viewModel.loadPrices()
            }
        }
    }
}
