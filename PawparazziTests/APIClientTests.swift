//
//  APIClientTests.swift
//  PawparazziTests
//
//  Created by ChatGPT on 12/2/25.
//

import Foundation
import Testing
@testable import Pawparazzi

struct APIClientTests {
    private struct SampleResponse: Codable, APIResponseEnvelope {
        let success: Bool
        let error: String
        let value: String
    }

    private struct MockSession: URLSessioning {
        let handler: (URLRequest) throws -> (Data, URLResponse)

        func data(for request: URLRequest) async throws -> (Data, URLResponse) {
            try handler(request)
        }
    }

    @Test func decodesEnvelopeAndQueryItems() async throws {
        let baseURL = URL(string: "https://example.com")!
        let environment = APIEnvironment(baseURL: baseURL)

        let mockSession = MockSession { request in
            #expect(request.httpMethod == HTTPMethod.get.rawValue)
            #expect(request.url?.absoluteString == "https://example.com/test?foo=bar")

            let httpResponse = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = """
            {
                "success": true,
                "error": "",
                "value": "ok"
            }
            """.data(using: .utf8)!
            return (data, httpResponse)
        }

        let client = APIClient(environment: environment, session: mockSession)
        let response: SampleResponse = try await client.send(
            path: "/test",
            method: .get,
            queryItems: [URLQueryItem(name: "foo", value: "bar")]
        )

        #expect(response.value == "ok")
    }

    @Test func throwsHTTPErrorForFailedEnvelope() async {
        let baseURL = URL(string: "https://example.com")!
        let environment = APIEnvironment(baseURL: baseURL)

        let mockSession = MockSession { request in
            let httpResponse = HTTPURLResponse(
                url: request.url!,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = """
            {
                "success": false,
                "error": "Unauthorized",
                "value": ""
            }
            """.data(using: .utf8)!
            return (data, httpResponse)
        }

        let client = APIClient(environment: environment, session: mockSession)

        await #expect {
            _ = try await client.send(
                path: "/test",
                method: .post
            ) as SampleResponse
        } throws: { error in
            guard case let APIError.http(status, message) = error else {
                return false
            }
            return status == 401 && message == "Unauthorized"
        }
    }
}

