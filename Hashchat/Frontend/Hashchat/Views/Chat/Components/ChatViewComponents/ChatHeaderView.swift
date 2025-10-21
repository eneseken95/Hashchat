//
//  ChatHeaderView.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 21.10.2025.
//

import SwiftUI

struct ChatHeaderView: View {
    @ObservedObject var chatViewModel: ChatViewModel
    @Binding var userColors: [String: Color]
    @Binding var showingUserList: Bool

    var body: some View {
        let otherUsers = Array(Set(chatViewModel.messages.map { $0.sender }).subtracting([chatViewModel.username]))

        if otherUsers.isEmpty {
            HStack(spacing: 8) {
                Circle().fill(Color.yellow).frame(width: 10, height: 10)
                TypingText("Searching for user...", isActive: true)
                    .font(.title2).fontWeight(.bold).foregroundStyle(Color.black.opacity(0.8))
            }
        } else if otherUsers.count == 1, let single = otherUsers.first {
            HStack(spacing: 8) {
                Circle().fill(Color.green).frame(width: 10, height: 10)
                Text(single).font(.title2).fontWeight(.bold).foregroundStyle(Color.black.opacity(0.8))
            }
        } else {
            Button { showingUserList = true } label: {
                HStack(spacing: 6) {
                    ForEach(Array(otherUsers.prefix(3)), id: \.self) { user in
                        Circle()
                            .fill(userColors[user] ?? .gray)
                            .frame(width: 28, height: 28)
                            .overlay(Text(String(user.prefix(1)).uppercased()).font(.system(size: 14, weight: .bold)).foregroundColor(.white))
                    }
                    if otherUsers.count > 3 { Text("...").font(.system(size: 14, weight: .bold)).foregroundColor(.gray) }
                }
            }
        }
    }
}
