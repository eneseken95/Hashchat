//
//  ConnectedUsersView.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 19.10.2025.
//

import SwiftUI

struct ConnectedUsersView: View {
    let users: [String]
    let isUserActive: (String) -> Bool
    @Environment(\.dismiss) var dismiss
    let userColors: [String: Color]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    Text("Connected Users")
                        .font(.title2)
                        .foregroundColor(.black)
                        .fontWeight(.bold)

                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color(red: 11 / 255, green: 185 / 255, blue: 255 / 255))
                                .fontWeight(.bold)
                        }
                    }
                }
                .padding()
                .background(Color.white)

                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(users, id: \.self) { user in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(userColors[user] ?? .gray)
                                    .frame(width: 45, height: 45)
                                    .overlay(
                                        Text(String(user.prefix(1)).uppercased())
                                            .font(.title3)
                                            .foregroundStyle(Color.white)
                                            .fontWeight(.bold)
                                    )

                                Text(user)
                                    .font(.headline)
                                    .foregroundStyle(Color.black)
                                    .fontWeight(.bold)
                                Spacer()
                                Text(isUserActive(user) ? "Active" : "Offline")
                                    .font(.headline)
                                    .foregroundColor(isUserActive(user) ? .green : .gray)
                                    .fontWeight(.bold)
                            }
                            .padding(.vertical, 4)

                            Divider()
                                .frame(height: 0.8)
                                .background(Color.gray)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 10)
            }
            .background(Color(red: 238 / 255, green: 239 / 255, blue: 238 / 255))
        }
    }
}

#Preview {
    let users = ["Enes", "Alperen", "Efe"]

    let colors = Dictionary(uniqueKeysWithValues: users.map { user in
        (user, Color(
            red: Double.random(in: 0.2 ... 0.9),
            green: Double.random(in: 0.2 ... 0.9),
            blue: Double.random(in: 0.2 ... 0.9)
        ))
    })

    ConnectedUsersView(
        users: users,
        isUserActive: { user in
            ["Enes", "Efe"].contains(user)
        },
        userColors: colors
    )
}
