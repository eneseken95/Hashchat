//
//  ChatToolbar.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 21.10.2025.
//

import SwiftUI

struct ChatToolbar: ToolbarContent {
    @ObservedObject var chatViewModel: ChatViewModel
    @Binding var userColors: [String: Color]
    @Binding var showingUserList: Bool
    @Binding var showingLogs: Bool
    var dismiss: () -> Void

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarLeading) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20.5, weight: .bold))
                    .foregroundColor(Color(red: 11 / 255, green: 185 / 255, blue: 255 / 255))
            }
        }

        ToolbarItem(placement: .principal) {
            ChatHeaderView(chatViewModel: chatViewModel, userColors: $userColors, showingUserList: $showingUserList)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
            Button { showingLogs = true } label: {
                Image(systemName: "terminal")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(red: 11 / 255, green: 185 / 255, blue: 255 / 255))
            }
        }
    }
}
