//
//  APIClient.swift
//  Pawparazzi
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation

protocol URLSessioning {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessioning {}

final class APIClient {
    private let environment: APIEnvironment
    private let session: URLSessioning
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        environment: APIEnvironment = .production,
        session: URLSessioning = URLSession.shared,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.environment = environment
        self.session = session
        self.encoder = encoder
        self.decoder = decoder

        // Match backend's snake_case keys
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.encoder.keyEncodingStrategy = .convertToSnakeCase

        // Fix for iOS 18.5 and below
        // The backend sends timestamps like "2025-12-05T04:21:06.983135+00:00"
        // which include fractional seconds. JSONDecoder.DateDecodingStrategy.iso8601
        // uses ISO8601DateFormatter without .withFractionalSeconds and will fail
        // to parse these, causing a decoding error.
        let iso8601WithFractionalSeconds = ISO8601DateFormatter()
        iso8601WithFractionalSeconds.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        self.decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            if let date = iso8601WithFractionalSeconds.date(from: dateString) {
                return date
            }

            // Fallback to the standard ISO8601 parser for any other valid formats.
            let fallbackFormatter = ISO8601DateFormatter()
            if let date = fallbackFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid ISO8601 date: \(dateString)"
            )
        }

        self.encoder.dateEncodingStrategy = .iso8601
    }

    func send<Response: Decodable & APIResponseEnvelope>(
        path: String,
        method: HTTPMethod,
        queryItems: [URLQueryItem]? = nil,
        body: (any Encodable)? = nil,
        headers: [String: String] = [:],
        timeout: TimeInterval = 30
    ) async throws -> Response {
        guard var components = URLComponents(url: environment.url(for: path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }

        if let queryItems = queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url, timeoutInterval: timeout)
        
        if ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 26 {
            request.assumesHTTP3Capable = false
        }

        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body = body {
            do {
                request.httpBody = try encoder.encode(AnyEncodable(body))
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw APIError.encodingFailed
            }
        }

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.network(underlying: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.network(underlying: URLError(.badServerResponse))
        }

        let decoded: Response
        do {
            decoded = try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decodingFailed(underlying: error)
        }

        guard decoded.success else {
            let message = decoded.error
            if !(200...299).contains(httpResponse.statusCode) {
                throw APIError.http(status: httpResponse.statusCode, message: message)
            }
            throw APIError.server(message: message)
        }

        return decoded
    }

    func getPlainText(
        path: String,
        timeout: TimeInterval = 15
    ) async throws -> String {
        guard let url = URL(string: path, relativeTo: environment.baseURL) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url, timeoutInterval: timeout)
        
        if ProcessInfo.processInfo.operatingSystemVersion.majorVersion < 26 {
            request.assumesHTTP3Capable = false
        }

        request.httpMethod = HTTPMethod.get.rawValue

        let (data, _) = try await session.data(for: request)
        guard let body = String(data: data, encoding: .utf8) else {
            throw APIError.decodingFailed(underlying: URLError(.cannotDecodeContentData))
        }

        return body
    }
}

