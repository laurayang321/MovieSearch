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
    
    @State private var loadedImage: UIImage? = nil
    @State private var isLoading: Bool = true
    
    var body: some View {
        if let loadedImage = loadedImage {
            Image(uiImage: loadedImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else if isLoading {
            ProgressView()
                .onAppear {
                    loadImage()
                }
        } else {
            placeholder
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
    }
    
    private func loadImage() {
        guard let url = url, url.absoluteString != "N/A" else {
            isLoading = false
            return
        }
        
        if let cachedImage = ImageCache.shared.getImage(for: url) {
            loadedImage = cachedImage
            isLoading = false
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    ImageCache.shared.setImage(image, for: url)
                    self.loadedImage = image
                    self.isLoading = false
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
        task.resume()
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
