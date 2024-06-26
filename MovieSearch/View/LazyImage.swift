//
//  LazyImage.swift
//  MovieSearch
//
//  Created by Jing Yang on 2024-06-25.
//

import SwiftUI

struct LazyImage: View {
    let url: URL?
    let placeholder: Image

    @State private var image: UIImage? = nil

    var body: some View {
        if let url = url, let cachedImage = ImageCache.shared.getImage(for: url) {
            Image(uiImage: cachedImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else if let url = url {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onAppear {
                            if let uiImage = image.asUIImage() {
                                ImageCache.shared.setImage(uiImage, for: url)
                            }
                        }
                case .failure:
                    placeholder
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                @unknown default:
                    placeholder
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
        } else {
            placeholder
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
}

private extension Image {
    func asUIImage() -> UIImage? {
        let controller = UIHostingController(rootView: self)
        let view = controller.view

        let targetSize = CGSize(width: 100, height: 180)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }
}
