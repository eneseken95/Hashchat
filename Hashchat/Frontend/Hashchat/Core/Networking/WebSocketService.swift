//
//  WebSocketService.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 12.10.2025.
//

import Combine
import Foundation

final class WebSocketService: ObservableObject {
    @Published var logs: [String] = []
    var cancellables = Set<AnyCancellable>()
    private var pingTimer: Timer?
    private var webSocketTask: URLSessionWebSocketTask?
    private lazy var url = URL(string: "ws://localhost:12345/ws")
    private var username: String = ""
    private var isConnecting = false
    private var reconnectAttempts = 0
    private let maxReconnectInterval: TimeInterval = 30
    let newMessage = PassthroughSubject<Message, Never>()

    func appendLog(_ text: String) {
        DispatchQueue.main.async {
            self.logs.append(text)
            print(text)
        }
    }

    func connect(username: String) {
        guard webSocketTask == nil && !isConnecting else {
            appendLog("WebSocket already connected or connecting for \(username)")
            return
        }

        self.username = username
        isConnecting = true
        let session = URLSession(configuration: .default)

        guard let url = url else {
            appendLog("WebSocket URL is invalid or nil")
            isConnecting = false
            return
        }

        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        appendLog("WebSocket connecting for \(username)")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            self.appendLog("WebSocket connected for \(username)")
            self.isConnecting = false
            self.reconnectAttempts = 0
            self.listen()
            self.startPinging()
        }
    }

    private func handleIncoming(text: String) {
        guard let data = text.data(using: .utf8),
              let msg = try? JSONDecoder().decode(Message.self, from: data) else {
            appendLog("Failed to decode JSON: \(text)")
            return
        }

        DispatchQueue.main.async {
            self.newMessage.send(msg)
            self.appendLog("Received: \(text)")
        }
    }

    private func listen() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(message):
                if case let .string(text) = message {
                    self.handleIncoming(text: text)
                }
                self.listen()
            case let .failure(error):
                self.appendLog("Receive error: \(error.localizedDescription)")
                self.cleanupAndReconnect()
            }
        }
    }

    func send(message: String) {
        let msg = Message(sender: username, message: message, timestamp: Date())

        guard let data = try? JSONEncoder().encode(msg),
              let jsonString = String(data: data, encoding: .utf8) else {
            appendLog("JSON encoding failed for message: \(message)")
            return
        }

        webSocketTask?.send(.string(jsonString)) { [weak self] error in
            if let error = error {
                self?.appendLog("Send error: \(error.localizedDescription)")
                self?.cleanupAndReconnect()
            } else {
                self?.appendLog("Sent JSON: \(jsonString)")
            }
        }
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        appendLog("WebSocket disconnected for \(username)")
        stopPinging()
        webSocketTask = nil
    }

    private func startPinging() {
        pingTimer = Timer.scheduledTimer(withTimeInterval: 45, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.webSocketTask?.sendPing { error in
                if let error = error {
                    self.appendLog("Ping failed: \(error.localizedDescription)")
                    self.cleanupAndReconnect()
                } else {
                    self.appendLog("Ping sent successfully")
                }
            }
        }
    }

    private func stopPinging() {
        pingTimer?.invalidate()
        pingTimer = nil
    }

    private func cleanupAndReconnect() {
        stopPinging()
        webSocketTask = nil
        guard !isConnecting else { return }

        reconnectAttempts += 1
        let interval = min(pow(2.0, Double(reconnectAttempts)), maxReconnectInterval)
        appendLog("Attempting to reconnect in \(Int(interval))s...")

        DispatchQueue.main.asyncAfter(deadline: .now() + interval) { [weak self] in
            guard let self = self, !self.isConnecting else { return }
            self.connect(username: self.username)
        }
    }
}
