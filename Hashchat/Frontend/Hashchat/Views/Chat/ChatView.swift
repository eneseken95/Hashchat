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
    @State private var showE2EEBanner = true

    var body: some View {
        ZStack {
            Image("ChatBackgraund")
                .resizable()
                .ignoresSafeArea()

            VStack {
                if chatViewModel.selectedCipher == .rsa && showE2EEBanner {
                    HStack {
                        Image(systemName: chatViewModel.recipientPublicKey != nil ? "lock.fill" : "lock.open.fill")
                            .foregroundColor(chatViewModel.recipientPublicKey != nil ? .green : .orange)

                        if chatViewModel.isLoadingRecipientKey {
                            ProgressView()
                                .scaleEffect(0.7)
                            Text("Fetching encryption key...")
                                .font(.footnote)
                        } else if let recipient = chatViewModel.recipientUsername {
                            Text(chatViewModel.recipientPublicKey != nil ? "Encrypted with \(recipient)" : "Waiting for \(recipient)'s key")
                                .font(.footnote)
                        }

                        Spacer()

                        Button(action: {
                            withAnimation {
                                showE2EEBanner = false
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .imageScale(.medium)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                MessagesView(
                    messages: chatViewModel.messages,
                    currentUsername: chatViewModel.username,
                    userColors: $userColors,
                    generateColors: generateUserColors
                )
            }
            .alert("Error", isPresented: .constant(chatViewModel.errorMessage != nil)) {
                Button("OK") {
                    chatViewModel.errorMessage = nil
                }
            } message: {
                Text(chatViewModel.errorMessage ?? "")
            }
            .safeAreaInset(edge: .bottom) {
                MessageInputView(chatViewModel: chatViewModel, safeAreaBottomInset: 0)
                    .background(Color.clear)
            }
            .onAppear {
                chatViewModel.webSocketService.connect(username: chatViewModel.username)
                userColors = generateUserColors(for: otherUsers)
            }
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
