//
//  SearchHistoryStore.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/1/25.
//

import Foundation
import Combine

/// 검색 기록을 관리하는 Store

actor SearchHistoryStore {
    
    // MARK: - Private Properties
    
    private let userDefaults: UserDefaults
    private let storageKey = "search.histories"
    private let maxCount = 10
    private let historiesSubject: CurrentValueSubject<[String], Never>
    
    // MARK: - Public Properties
    
    /// ViewController가 구독할 읽기 전용 Publisher
    var historiesPublisher: AnyPublisher<[String], Never> {
        historiesSubject.eraseToAnyPublisher()
    }
    
    /// 현재 검색 기록 목록
    var currentHistories: [String] {
        historiesSubject.value
    }
    
    // MARK: - Initialization
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        let loadedHistories = userDefaults.stringArray(forKey: storageKey) ?? []
        self.historiesSubject = CurrentValueSubject(loadedHistories)
    }
    
    // MARK: - Public Methods
    
    /// 검색 기록 추가
    /// 
    /// - Parameter query: 추가할 검색어
    /// 
    /// 빈 문자열이나 공백만 있는 경우 추가하지 않음
    /// 중복된 검색어는 제거하고 맨 앞에 추가
    /// 최대 개수를 초과하면 오래된 기록 제거
    func addHistory(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        var histories = historiesSubject.value
            .filter { $0.caseInsensitiveCompare(trimmed) != .orderedSame }
        histories.insert(trimmed, at: 0)
        
        if histories.count > maxCount {
            histories = Array(histories.prefix(maxCount))
        }
        
        historiesSubject.send(histories)
        userDefaults.set(histories, forKey: storageKey)
    }
    
    /// 검색 기록 불러오기
    func loadHistories() -> [String] {
        historiesSubject.value
    }
    
    /// 검색 기록 모두 삭제
    func clear() {
        historiesSubject.send([])
        userDefaults.removeObject(forKey: storageKey)
    }
}
