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
    @State var showingLogs = false
    @State var showingUserList = false
    @State var userColors: [String: Color] = [:]

    var body: some View {
        ZStack {
            Image("ChatBackgraund")
                .resizable()
                .ignoresSafeArea()

            VStack {
                MessagesView(
                    messages: chatViewModel.messages,
                    currentUsername: chatViewModel.username,
                    userColors: $userColors,
                    generateColors: generateUserColors
                )
                MessageInputView(chatViewModel: chatViewModel, safeAreaBottomInset: safeAreaBottomInset())
            }
            .onAppear {
                chatViewModel.webSocketService.connect(username: chatViewModel.username)
                userColors = generateUserColors(for: otherUsers)
            }
            .ignoresSafeArea(edges: .bottom)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ChatToolbar(
                    chatViewModel: chatViewModel,
                    userColors: $userColors,
                    showingUserList: $showingUserList,
                    showingLogs: $showingLogs,
                    dismiss: { dismiss() }
                )
            }
            .toolbarBackground(Color(red: 247 / 255, green: 248 / 255, blue: 247 / 255), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showingUserList) { ConnectedUsersView(users: otherUsers, isUserActive: isUserActive, userColors: userColors) }
            .sheet(isPresented: $showingLogs) {
                WebSocketLogView()
                    .environmentObject(chatViewModel.webSocketService)
            }
        }
    }

    func safeAreaBottomInset() -> CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0
    }
}

#Preview {
    NavigationStack {
        ChatView()
            .environmentObject(ChatViewModel(username: "Enes", webSocketService: WebSocketService()))
            .environmentObject(WebSocketService())
    }
}
