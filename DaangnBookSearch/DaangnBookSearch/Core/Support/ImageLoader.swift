//
//  ImageLoader.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/1/25.
//

import UIKit
import CryptoKit

enum ImageLoaderError: Error {
    case invalidData
}

final class ImageLoader {

    static let shared = ImageLoader()

    private let memoryCache = NSCache<NSURL, UIImage>()
    private let fileManager = FileManager.default
    private let ioQueue = DispatchQueue(label: "kr.daangn.imageloader.io", qos: .utility)
    private let cacheDirectory: URL

    private init() {
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        cacheDirectory = caches.appendingPathComponent("ImageCache", isDirectory: true)
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
        memoryCache.countLimit = 200
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50MB
    }

    func loadImage(from url: URL) async throws -> UIImage {
        if let cached = memoryCache.object(forKey: url as NSURL) {
            return cached
        }

        if let diskImage = loadImageFromDisk(for: url) {
            memoryCache.setObject(diskImage, forKey: url as NSURL)
            return diskImage
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        guard let image = UIImage(data: data) else {
            throw ImageLoaderError.invalidData
        }

        memoryCache.setObject(image, forKey: url as NSURL)
        storeImageToDisk(data, for: url)
        return image
    }

    func clearMemoryCache() {
        memoryCache.removeAllObjects()
    }

    func removeImage(for url: URL) {
        memoryCache.removeObject(forKey: url as NSURL)
        let fileURL = cacheDirectory.appendingPathComponent(filename(for: url))
        ioQueue.async { [weak self] in
            try? self?.fileManager.removeItem(at: fileURL)
        }
    }

    private func loadImageFromDisk(for url: URL) -> UIImage? {
        let fileURL = cacheDirectory.appendingPathComponent(filename(for: url))
        guard fileManager.fileExists(atPath: fileURL.path) else { return nil }
        return UIImage(contentsOfFile: fileURL.path)
    }

    private func storeImageToDisk(_ data: Data, for url: URL) {
        let fileURL = cacheDirectory.appendingPathComponent(filename(for: url))
        ioQueue.async { [weak self] in
            guard let self else { return }
            if !self.fileManager.fileExists(atPath: fileURL.deletingLastPathComponent().path) {
                try? self.fileManager.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            }
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    private func filename(for url: URL) -> String {
        let data = Data(url.absoluteString.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}


