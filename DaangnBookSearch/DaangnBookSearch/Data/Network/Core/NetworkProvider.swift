//
//  NetworkProvider.swift
//  DaangnBookSearch
//
//  Created by 민성홍 on 10/30/25.
//

import Foundation

final class NetworkProvider {
    private let session: URLSession
    init(session: URLSession = .shared) { self.session = session }

    func request<T: Decodable>(_ target: NetworkTarget, as type: T.Type) async throws -> T {
        var comp = URLComponents(url: target.baseURL.appendingPathComponent(target.path), resolvingAgainstBaseURL: false)!
        comp.queryItems = (target.queryItems?.isEmpty == false) ? target.queryItems : nil
        guard let url = comp.url else { throw URLError(.badURL) }

        var req = URLRequest(url: url)
        req.httpMethod = target.method.rawValue
        target.headers?.forEach { req.addValue($0.value, forHTTPHeaderField: $0.key) }
        req.httpBody = target.body

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
