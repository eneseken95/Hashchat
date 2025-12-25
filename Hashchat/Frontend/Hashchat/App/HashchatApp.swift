//
//  HashchatApp.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 11.10.2025.
//

import SwiftUI

@main
struct HashchatApp: App {
    init() {
        _ = Crypto.RSA.shared

        runCryptoBenchmark()
    }

    var body: some Scene {
        WindowGroup {
            JoinChatView()
                .environmentObject(JoinChatViewModel())
                .environmentObject(WebSocketService())
        }
    }
}
