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
        TextField("", text: $username, prompt: Text("User name").foregroundColor(.gray))
            .padding(12)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray, lineWidth: 2)
            )
            .foregroundColor(.black)
            .fontWeight(.bold)
            .padding(.horizontal, 25)
            .padding(.bottom, 5)
    }
}

#Preview {
    UsernameFieldView(username: .constant("Enes"))
}
