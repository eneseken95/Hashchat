//
//  HashchatApp.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 11.10.2025.
//

import SwiftUI

@main
struct HashchatApp: App {
    @StateObject var joinChatViewModel = JoinChatViewModel()
    @StateObject var webSocketService: WebSocketService
    @StateObject var chatViewModel: ChatViewModel

    init() {
        let webSocket = WebSocketService()
        _webSocketService = StateObject(wrappedValue: webSocket)
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(username: "", webSocketService: webSocket))
        
        runCryptoBenchmark()
    }

    var body: some Scene {
        WindowGroup {
            JoinChatView()
                .environmentObject(joinChatViewModel)
                .environmentObject(chatViewModel)
                .environmentObject(webSocketService)
        }
    }
}
