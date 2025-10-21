//
//  MessagesView.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 21.10.2025.
//

import SwiftUI

struct MessagesView: View {
    let messages: [Message]
    let currentUsername: String
    @Binding var userColors: [String: Color]
    var generateColors: ([String]) -> [String: Color]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(messages) { msg in
                        MessageBubble(
                            message: msg,
                            isCurrentUser: msg.sender == currentUsername,
                            userColors: userColors
                        )
                        .id(msg.id)
                    }
                }
                .padding()
            }
            .onChange(of: messages.count) { _, _ in
                let allUsers = Array(Set(messages.map { $0.sender }))
                userColors = generateColors(allUsers)
                if let last = messages.last {
                    proxy.scrollTo(last.id, anchor: .bottom)
                }
            }
        }
    }
}
