//
//  BookshelfStore.swift
//  DaangnBookSearch
//
//  Created by Assistant on 11/02/25.
//

import Foundation
import Combine

/// 즐겨찾기 데이터를 관리하는 Shared Store
public actor BookshelfStore {
    
    // MARK: - Private Properties
    
    private let booksSubject: CurrentValueSubject<[BookSummary], Never>
    
    // MARK: - Public Properties
    
    /// ViewModel이 구독할 읽기 전용 Publisher
    public var booksPublisher: AnyPublisher<[BookSummary], Never> {
        booksSubject.eraseToAnyPublisher()
    }
    
    /// 현재 즐겨찾기 목록
    public var currentBooks: [BookSummary] {
        booksSubject.value
    }
    
    /// 현재 즐겨찾기 ISBN Set (빠른 확인용)
    public var favoriteISBNs: Set<String> {
        Set(booksSubject.value.map { $0.isbn13 })
    }
    
    // MARK: - Initialization
    
    public init(initialBooks: [BookSummary] = []) {
        self.booksSubject = CurrentValueSubject(initialBooks)
    }
    
    // MARK: - Internal Methods (UseCase에서만 호출)
    
    /// UseCase를 통해서만 호출
    func add(_ book: BookSummary) {
        guard !favoriteISBNs.contains(book.isbn13) else {
            return
        }
        
        var updatedBooks = booksSubject.value
        updatedBooks.insert(book, at: 0)
        booksSubject.send(updatedBooks)
    }
    
    /// UseCase를 통해서만 호출
    func remove(isbn13: String) {
        var updatedBooks = booksSubject.value
        
        guard let index = updatedBooks.firstIndex(where: { $0.isbn13 == isbn13 }) else {
            return
        }
        
        updatedBooks.remove(at: index)
        booksSubject.send(updatedBooks)
    }
    
    /// UseCase를 통해서만 호출
    func toggle(_ book: BookSummary) -> Bool {
        if favoriteISBNs.contains(book.isbn13) {
            remove(isbn13: book.isbn13)
            return false
        } else {
            add(book)
            return true
        }
    }
    
    /// UseCase를 통해서만 호출
    func updateBooks(_ books: [BookSummary]) {
        booksSubject.send(books)
    }
    
    /// ISBN으로 즐겨찾기 여부 확인
    func contains(isbn13: String) -> Bool {
        favoriteISBNs.contains(isbn13)
    }
}
