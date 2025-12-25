//
//  RecipientUsernameFieldView.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 25.12.2025.
//

import SwiftUI

struct RecipientUsernameFieldView: View {
    @Binding var recipientUsername: String

    var body: some View {
        TextField("", text: $recipientUsername, prompt: Text("Recipient User name").foregroundColor(.gray))
            .padding(12)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray, lineWidth: 2)
            )
            .foregroundColor(.black)
            .fontWeight(.bold)
            .padding(.horizontal, 25)
            .padding(.bottom, 5)
            .autocapitalization(.none)
            .autocorrectionDisabled()
    }
}

#Preview {
    RecipientUsernameFieldView(recipientUsername: .constant("Enes"))
}
