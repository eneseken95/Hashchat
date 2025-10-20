//
//  ChatView.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 12.10.2025.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var chatViewModel: ChatViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingLogs = false
    @State private var showingUserList = false
    @State private var userColors: [String: Color] = [:]
    private func safeAreaBottomInset() -> CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0
    }

    private func isUserActive(_ user: String) -> Bool {
        if let lastMsg = chatViewModel.messages.last(where: { $0.sender == user }) {
            let diff = Date().timeIntervalSince(lastMsg.timestamp)
            return diff < 60
        }
        return false
    }

    private var otherUsers: [String] {
        Array(Set(chatViewModel.messages.compactMap { msg in
            msg.sender != chatViewModel.username ? msg.sender : nil
        }))
    }

    private func generateUserColors(for users: [String]) -> [String: Color] {
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

    var body: some View {
        ZStack {
            Image("ChatBackgraund")
                .resizable()
                .ignoresSafeArea()

            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(chatViewModel.messages) { msg in
                                MessageBubble(
                                    message: msg,
                                    isCurrentUser: msg.sender == chatViewModel.username,
                                    userColors: userColors
                                )
                                .id(msg.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: chatViewModel.messages.count) { _, _ in
                        let allUsers = Array(Set(chatViewModel.messages.map { $0.sender }))
                        userColors = generateUserColors(for: allUsers)
                        if let last = chatViewModel.messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }

                HStack(spacing: 12) {
                    TextField("Write a message...", text: $chatViewModel.messageText)
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(red: 247 / 255, green: 248 / 255, blue: 247 / 255))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(red: 11 / 255, green: 185 / 255, blue: 255 / 255), lineWidth: 2.5)
                        )
                        .foregroundColor(.black)
                        .fontWeight(.bold)

                    Button(action: {
                        chatViewModel.sendMessage()
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                            .padding(14)
                            .background(
                                Color(red: 11 / 255, green: 185 / 255, blue: 255 / 255)
                            )
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.25), radius: 2, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(red: 247 / 255, green: 248 / 255, blue: 247 / 255))
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                .padding(.bottom, safeAreaBottomInset())
            }
            .onAppear {
                chatViewModel.webSocketService.connect(username: chatViewModel.username)
                userColors = generateUserColors(for: otherUsers)
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20.5, weight: .bold))
                            .foregroundColor(Color(red: 11 / 255, green: 185 / 255, blue: 255 / 255))
                    }
                }

                ToolbarItem(placement: .principal) {
                    let otherUsers = Array(Set(chatViewModel.messages.compactMap { msg in
                        msg.sender != chatViewModel.username ? msg.sender : nil
                    }))

                    let userColors = generateUserColors(for: otherUsers)

                    if otherUsers.isEmpty {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 10, height: 10)
                            TypingText("Searching for user...", isActive: true)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.black.opacity(0.8))
                        }
                    } else if otherUsers.count == 1, let single = otherUsers.first {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 10, height: 10)
                            Text(single)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.black.opacity(0.8))
                        }
                    } else {
                        Button(action: { showingUserList = true }) {
                            HStack(spacing: 6) {
                                let displayedUsers = Array(otherUsers.prefix(3))
                                ForEach(displayedUsers, id: \.self) { user in
                                    let initials = String(user.prefix(1)).uppercased()
                                    Circle()
                                        .fill(userColors[user] ?? .gray)
                                        .frame(width: 28, height: 28)
                                        .overlay(
                                            Text(initials)
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                }

                                if otherUsers.count > 2 {
                                    Text("...")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingLogs = true
                    }) {
                        Image(systemName: "terminal")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(red: 11 / 255, green: 185 / 255, blue: 255 / 255))
                    }
                }
            }
            .toolbarBackground(Color(red: 247 / 255, green: 248 / 255, blue: 247 / 255), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)

            .sheet(isPresented: $showingUserList) {
                let otherUsers = Array(Set(chatViewModel.messages.compactMap { msg in
                    msg.sender != chatViewModel.username ? msg.sender : nil
                }))

                let userColors = generateUserColors(for: otherUsers)

                ConnectedUsersView(users: otherUsers, isUserActive: isUserActive, userColors: userColors)
            }

            .sheet(isPresented: $showingLogs) {
                NavigationStack {
                    WebSocketLogView()
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                Text("WebSocket Logs")
                                    .font(.title2)
                                    .foregroundColor(.black)
                                    .fontWeight(.bold)
                            }

                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    showingLogs = false
                                }) {
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(Color(red: 11 / 255, green: 185 / 255, blue: 255 / 255))
                                        .fontWeight(.bold)
                                }
                            }
                        }
                        .toolbarBackground(Color(red: 247 / 255, green: 248 / 255, blue: 247 / 255), for: .navigationBar)
                        .toolbarBackground(.visible, for: .navigationBar)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatView()
            .environmentObject(ChatViewModel(username: "Enes", webSocketService: WebSocketService()))
            .environmentObject(WebSocketService())
    }
}
