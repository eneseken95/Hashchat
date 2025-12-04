//
//  MessageInputView.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 21.10.2025.
//

import SwiftUI

struct MessageInputView: View {
    @ObservedObject var chatViewModel: ChatViewModel
    let safeAreaBottomInset: CGFloat

    var body: some View {
        HStack(spacing: 12) {
            TextField("", text: $chatViewModel.messageText, axis: .vertical)
                .lineLimit(...4)
                .placeholder(when: chatViewModel.messageText.isEmpty) {
                    Text("Write a message...")
                        .foregroundColor(.gray)
                        .fontWeight(.bold)
                        .padding(.leading, 4)
                }
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
                .animation(.easeInOut(duration: 0.2), value: chatViewModel.messageText)

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
            .disabled(chatViewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .opacity(chatViewModel.messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1.0)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(red: 247 / 255, green: 248 / 255, blue: 247 / 255))
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.bottom, safeAreaBottomInset)
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    MessageInputView(
        chatViewModel: ChatViewModel(
            username: "Enes",
            webSocketService: WebSocketService()
        ),
        safeAreaBottomInset: 0
    )
    .padding()
    .background(Color.gray.opacity(0.1))
}
