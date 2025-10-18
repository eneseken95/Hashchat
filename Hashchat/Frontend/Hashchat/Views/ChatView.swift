//
//  ChatView.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 12.10.2025.
//

import SwiftUI

struct ChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showingLogs = false

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.messages) { msg in
                            MessageBubble(message: msg, isCurrentUser: msg.sender == viewModel.username)
                                .id(msg.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) { _, _ in
                    if let last = viewModel.messages.last {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }

            HStack(spacing: 12) {
                TextField("Write a message...", text: $viewModel.messageText)
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
                    viewModel.sendMessage()
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
            viewModel.webSocketService.connect(username: viewModel.username)
        }
        .background(Color(red: 238 / 255, green: 239 / 255, blue: 238 / 255))
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
                HStack(spacing: 8) {
                    if let chatPartner = viewModel.messages.first(where: { $0.sender != viewModel.username })?.sender {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 10, height: 10)

                        Text(chatPartner)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.black.opacity(0.8))
                    } else {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.yellow)
                                .frame(width: 10, height: 10)

                            TypingText("Searching for user...", isActive: true)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.black.opacity(0.8))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingLogs = true
                }) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(red: 11 / 255, green: 185 / 255, blue: 255 / 255))
                }
            }
        }
        .toolbarBackground(Color(red: 247 / 255, green: 248 / 255, blue: 247 / 255), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showingLogs) {
            NavigationStack {
                WebSocketLogView(wsService: viewModel.webSocketService)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Text("WebSocket Logs")
                                .font(.title3)
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                        }

                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                showingLogs = false
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color(red: 11 / 255, green: 185 / 255, blue: 255 / 255))
                            }
                        }
                    }
                    .toolbarBackground(Color(red: 247 / 255, green: 248 / 255, blue: 247 / 255), for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
            }
        }
    }

    private func safeAreaBottomInset() -> CGFloat {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.safeAreaInsets.bottom ?? 0
    }
}

#Preview {
    NavigationStack {
        ChatView(viewModel: ChatViewModel(username: "Enes"))
    }
}
