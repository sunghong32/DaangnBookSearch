//
//  SearchHistoryStore.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/1/25.
//

import Foundation

final class SearchHistoryStore {

    static let shared = SearchHistoryStore()

    private let userDefaults = UserDefaults.standard
    private let key = "search.histories"
    private let maxCount = 10

    private init() {}

    func addHistory(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var histories = loadHistories().filter { $0.caseInsensitiveCompare(trimmed) != .orderedSame }
        histories.insert(trimmed, at: 0)
        if histories.count > maxCount {
            histories = Array(histories.prefix(maxCount))
        }
        userDefaults.set(histories, forKey: key)
    }

    func loadHistories() -> [String] {
        userDefaults.stringArray(forKey: key) ?? []
    }

    func clear() {
        userDefaults.removeObject(forKey: key)
    }
}


