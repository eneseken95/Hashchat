//
//  JoinChatView+Helpers.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 21.10.2025.
//

import SwiftUI

extension JoinChatView {
    static func cipherTextField(_ placeholder: String, intBinding: Binding<Int?>) -> some View {
        TextField(placeholder, text: Binding(
            get: { intBinding.wrappedValue.map { String($0) } ?? "" },
            set: { intBinding.wrappedValue = Int($0) }
        ))
        .keyboardType(.numberPad)
        .padding(12)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.8), lineWidth: 2))
        .foregroundColor(.black)
        .fontWeight(.bold)
        .padding(.horizontal, 25)
        .padding(.top, 15)
    }

    static func cipherTextField(_ placeholder: String, stringBinding: Binding<String?>) -> some View {
        TextField(placeholder, text: Binding(
            get: { stringBinding.wrappedValue ?? "" },
            set: { stringBinding.wrappedValue = $0.isEmpty ? nil : $0 }
        ))
        .padding(12)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.8), lineWidth: 2))
        .foregroundColor(.black)
        .fontWeight(.bold)
        .padding(.horizontal, 25)
        .padding(.top, 15)
    }

    static func hillCipherView(hillBinding: @escaping (Int, Int) -> Binding<String>, encryption: Bool) -> some View {
        VStack(spacing: 5) {
            Text("Enter 2x2 \(encryption ? "Encryption" : "Decryption") Hill Cipher Key")
                .foregroundColor(.gray)
                .fontWeight(.bold)
                .padding(.top, 10)

            ForEach(0 ..< 2, id: \.self) { row in
                HStack {
                    ForEach(0 ..< 2, id: \.self) { col in
                        TextField("", text: hillBinding(row, col))
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.8), lineWidth: 1))
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
