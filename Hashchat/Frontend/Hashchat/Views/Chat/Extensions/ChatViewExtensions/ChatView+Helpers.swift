//
//  ChatView+Helpers.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 21.10.2025.
//

import SwiftUI

extension ChatView {
    var otherUsers: [String] {
        Array(Set(chatViewModel.messages.compactMap { msg in
            msg.sender != chatViewModel.username ? msg.sender : nil
        }))
    }

    func isUserActive(_ user: String) -> Bool {
        if let lastMsg = chatViewModel.messages.last(where: { $0.sender == user }) {
            let diff = Date().timeIntervalSince(lastMsg.timestamp)
            return diff < 60
        }
        return false
    }

    func generateUserColors(for users: [String]) -> [String: Color] {
        var colors = userColors

        let letterColors: [Character: Color] = [
            "A": .purple, "B": .purple, "C": .green, "Ç": .orange,
            "D": .pink, "E": .orange, "F": .yellow, "G": .mint,
            "H": .teal, "I": .indigo, "İ": .cyan, "J": .brown,
            "K": .red, "L": .purple, "M": .pink, "N": .orange,
            "O": .pink, "Ö": .purple, "P": .yellow, "R": .mint,
            "S": .teal, "Ş": .indigo, "T": .cyan, "U": .brown,
            "Ü": .red, "V": .purple, "Y": .green, "Z": .orange,
        ]

        for user in users {
            if colors[user] == nil {
                if let first = user.uppercased().first {
                    colors[user] = letterColors[first] ?? Color(
                        red: Double.random(in: 0.2 ... 0.9),
                        green: Double.random(in: 0.2 ... 0.9),
                        blue: Double.random(in: 0.2 ... 0.9)
                    )
                } else {
                    colors[user] = .gray
                }
            }
        }

        return colors
    }
}
