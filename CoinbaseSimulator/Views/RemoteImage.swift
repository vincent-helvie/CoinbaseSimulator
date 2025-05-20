//
//  RemoteImage.swift
//  CoinbaseSimulator
//
//  Created by vincent helvie on 5/20/25.
//

import SwiftUI

struct RemoteImage: View {
    @StateObject private var loader: ImageLoader
    var placeholder: Image

    init(url: String?, placeholder: Image = Image(systemName: "photo")) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
        self.placeholder = placeholder
    }

    var body: some View {
        if let image = loader.image {
            Image(uiImage: image)
                .resizable()
        } else {
            placeholder
                .resizable()
                .opacity(0.3)
        }
    }
}

private class ImageLoader: ObservableObject {
    @Published var image: UIImage?

    init(url: String?) {
        guard let url = URL(string: url ?? "") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let img = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.image = img
                }
            }
        }.resume()
    }
}
