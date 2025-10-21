//
//  UsernameFieldView.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 21.10.2025.
//

import SwiftUI

struct UsernameFieldView: View {
    @Binding var username: String

    var body: some View {
        TextField("User name", text: $username)
            .padding(12)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.8), lineWidth: 2))
            .foregroundColor(.black)
            .fontWeight(.bold)
            .padding(.horizontal, 25)
            .padding(.bottom, 5)
    }
}

#Preview {
    UsernameFieldView(username: .constant("Enes"))
}
