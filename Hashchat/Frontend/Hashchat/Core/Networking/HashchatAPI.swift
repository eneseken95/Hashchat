//
//  HashchatAPI.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 25.12.2025.
//

import Foundation

final class HashchatAPI {
    static let shared = HashchatAPI()

    private let baseURL = "http://localhost:12345"
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        session = URLSession(configuration: config)
    }

    func registerUser(username: String, publicKey: String) async throws {
        guard let url = URL(string: "\(baseURL)/register") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "username": username,
            "public_key": publicKey,
        ]

        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 400 {
            if let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.userAlreadyExists(errorData.detail)
            }
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }

        print("User '\(username)' registered successfully")
    }

    func getPublicKey(for username: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/users/\(username)/public-key") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        if httpResponse.statusCode == 404 {
            throw APIError.userNotFound(username)
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(statusCode: httpResponse.statusCode)
        }

        let publicKeyResponse = try JSONDecoder().decode(PublicKeyResponse.self, from: data)
        print("Retrieved public key for '\(username)'")
        return publicKeyResponse.publicKey
    }

    func checkHealth() async -> Bool {
        guard let url = URL(string: "\(baseURL)/health") else {
            return false
        }

        do {
            let (_, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else {
                return false
            }
            return (200 ... 299).contains(httpResponse.statusCode)
        } catch {
            print("Health check failed:", error.localizedDescription)
            return false
        }
    }
}

private struct PublicKeyResponse: Codable {
    let username: String
    let publicKey: String

    enum CodingKeys: String, CodingKey {
        case username
        case publicKey = "public_key"
    }
}

private struct ErrorResponse: Codable {
    let detail: String
}

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int)
    case userNotFound(String)
    case userAlreadyExists(String)
    case networkError(Error)

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid server response"
        case let .serverError(code):
            return "Server error (status: \(code))"
        case let .userNotFound(username):
            return "User '\(username)' not found. Make sure they are registered."
        case let .userAlreadyExists(message):
            return message
        case let .networkError(error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
