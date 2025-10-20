//
//  MessageBubble.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 17.10.2025.
//

import SwiftUI

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    let userColors: [String: Color]

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            if isCurrentUser {
                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.sender)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.trailing)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(message.message)
                        .font(.headline)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.trailing)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .padding(.trailing, 8)
                .background(
                    BubbleShape(isCurrentUser: true)
                        .fill(Color(red: 11 / 255, green: 185 / 255, blue: 255 / 255))
                )
                .frame(maxWidth: UIScreen.main.bounds.width * 0.50, alignment: .trailing)
                .fixedSize(horizontal: false, vertical: true)

                Circle()
                    .fill(userColors[message.sender] ?? Color.black)
                    .frame(width: 34, height: 34)
                    .overlay(
                        Text(String(message.sender.prefix(1)).uppercased())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    )
            } else {
                Circle()
                    .fill(userColors[message.sender] ?? Color.black)
                    .frame(width: 34, height: 34)
                    .overlay(
                        Text(String(message.sender.prefix(1)).uppercased())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(message.sender)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.trailing)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(message.message)
                        .font(.headline)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .padding(.leading, 8)
                .background(
                    BubbleShape(isCurrentUser: false)
                        .fill(Color.gray)
                )
                .frame(maxWidth: UIScreen.main.bounds.width * 0.50, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
        }
        .padding(isCurrentUser ? .leading : .trailing, 50)
        .padding(.vertical, 4)
        .animation(.easeInOut(duration: 0.2), value: message.message)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VStack(spacing: 16) {
        MessageBubble(
            message: Message(sender: "Enes", message: "Hey! How are you?", timestamp: Date()),
            isCurrentUser: true,
            userColors: ["Enes": .blue, "Efe": .green]
        )

        MessageBubble(
            message: Message(sender: "Efe", message: "I'm good, thanks!", timestamp: Date()),
            isCurrentUser: false,
            userColors: ["Enes": .blue, "Efe": .green]
        )
    }
    .padding()
    .background(Color(red: 238 / 255, green: 239 / 255, blue: 238 / 255))
}
