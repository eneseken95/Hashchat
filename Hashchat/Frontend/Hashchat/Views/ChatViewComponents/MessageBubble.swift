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

    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
                Text(message.message)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .padding(.vertical, 10)
                    .padding(EdgeInsets(top: 0, leading: 14, bottom: 0, trailing: 22))
                    .background(
                        BubbleShape(isCurrentUser: true)
                            .fill(Color(red: 11 / 255, green: 185 / 255, blue: 255 / 255))
                    )
                    .frame(maxWidth: 250, alignment: .trailing)
            } else {
                Text(message.message)
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .padding(.vertical, 10)
                    .padding(EdgeInsets(top: 0, leading: 22, bottom: 0, trailing: 14))
                    .background(
                        BubbleShape(isCurrentUser: false)
                            .fill(Color.gray.opacity(0.2))
                    )
                    .frame(maxWidth: 250, alignment: .leading)
                Spacer()
            }
        }
        .padding(isCurrentUser ? .leading : .trailing, 50)
        .padding(.vertical, 4)
        .animation(.easeInOut(duration: 0.2), value: message.message)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VStack(spacing: 20) {
        MessageBubble(
            message: Message(sender: "Enes", message: "Hey! How are you?"),
            isCurrentUser: true
        )

        MessageBubble(
            message: Message(sender: "Alex", message: "I'm good, thanks!"),
            isCurrentUser: false
        )
    }
    .padding()
    .background(Color(red: 238 / 255, green: 239 / 255, blue: 238 / 255))
}
