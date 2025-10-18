//
//  WebSocketLogView.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 18.10.2025.
//

import SwiftUI

struct WebSocketLogView: View {
    @ObservedObject var wsService: WebSocketService

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(wsService.logs.enumerated()), id: \.offset) { index, log in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(index + 1) ")
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .frame(width: 25, alignment: .trailing)

                            Text(log)
                                .font(.system(.subheadline, design: .monospaced))
                                .foregroundColor(.green)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                        }
                        .id(index)
                    }
                }
                .padding()
            }
            .onChange(of: wsService.logs.count) {
                if let lastIndex = wsService.logs.indices.last {
                    proxy.scrollTo(lastIndex, anchor: .bottom)
                }
            }
        }
        .background(Color.black.opacity(0.9))
    }
}

#Preview {
    let mockWS = WebSocketService()
    mockWS.logs = [
        "Connected to server",
        "Sent message: Hello!",
        "Received message: Hi there!",
        "Connection closed unexpectedly",
    ]

    return WebSocketLogView(wsService: mockWS)
        .frame(width: 350, height: 300)
}
