//
//  JoinButtonView.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 21.10.2025.
//

import SwiftUI

struct JoinButtonView: View {
    let username: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Join Chat")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(LinearGradient(colors: [.cyan.opacity(0.8), .blue], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 3)
        }
        .padding(.horizontal, 25)
        .padding(.top, 10)
        .disabled(!isEnabled)
        .opacity(!isEnabled ? 0.5 : 1.0)
    }
}
