//
//  JoinChatView+Helpers.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 21.10.2025.
//

import SwiftUI

extension JoinChatView {
    static func cipherTextField(_ placeholder: String, intBinding: Binding<Int?>) -> some View {
        TextField("", text: Binding(
            get: { intBinding.wrappedValue.map { String($0) } ?? "" },
            set: { intBinding.wrappedValue = Int($0) }
        ), prompt: Text(placeholder).foregroundStyle(.gray))
            .keyboardType(.numberPad)
            .padding(12)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.8), lineWidth: 2))
            .foregroundColor(.black)
            .fontWeight(.bold)
            .padding(.horizontal, 25)
            .padding(.top, 15)
    }

    static func cipherTextField(_ placeholder: String, stringBinding: Binding<String?>) -> some View {
        TextField("", text: Binding(
            get: { stringBinding.wrappedValue ?? "" },
            set: { stringBinding.wrappedValue = $0.isEmpty ? nil : $0 }
        ), prompt: Text(placeholder).foregroundStyle(.gray))
            .padding(12)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.8), lineWidth: 2))
            .foregroundColor(.black)
            .fontWeight(.bold)
            .padding(.horizontal, 25)
            .padding(.top, 15)
    }

    static func hillCipherView(hillBinding: @escaping (Int, Int) -> Binding<String>, encryption: Bool) -> some View {
        VStack(spacing: 8) {
            Text("Enter 2x2 \(encryption ? "Encryption" : "Decryption") Hill Cipher Key")
                .foregroundColor(.gray)
                .fontWeight(.bold)
                .padding(.top, 10)

            ForEach(0 ..< 2, id: \.self) { row in
                HStack {
                    ForEach(0 ..< 2, id: \.self) { col in
                        TextField("", text: hillBinding(row, col))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 150, height: 30)
                            .foregroundColor(.black)
                            .tint(.black)
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.gray.opacity(0.8), lineWidth: 2))
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                    }
                }
            }
        }
        .padding(.horizontal)
    }

    func isCipherInputValid() -> Bool {
        let trimmed = joinChatViewModel.username.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return false }

        switch selectedEncryption {
        case .caesar: if caesarEncryptionShift == nil { return false }
        case .vigenere: if vigenereEncryptionKey?.isEmpty ?? true { return false }
        case .columnar: if columnarEncryptionKey?.isEmpty ?? true { return false }
        case .hill: if hillEncryptionKey.flatMap({ $0 }).contains(nil) { return false }
        case .railfence: if railFenceEncryptionRails == nil { return false }
        case .euclid: if euclidEncryptionKey == nil { return false }
        case .aes:
            if aesEncryptionKey?.isEmpty ?? true { return false }
            if aesEncryptionKey!.count < 1 { return false }
        case .des:
            if desEncryptionKey?.isEmpty ?? true { return false }
            if desEncryptionKey!.count != 8 { return false }
        default: break
        }

        switch selectedDecryption {
        case .caesar: if caesarDecryptionShift == nil { return false }
        case .vigenere: if vigenereDecryptionKey?.isEmpty ?? true { return false }
        case .columnar: if columnarDecryptionKey?.isEmpty ?? true { return false }
        case .hill: if hillDecryptionKey.flatMap({ $0 }).contains(nil) { return false }
        case .railfence: if railFenceDecryptionRails == nil { return false }
        case .euclid: if euclidDecryptionKey == nil { return false }
        case .aes:
            if aesDecryptionKey?.isEmpty ?? true { return false }
            if aesDecryptionKey!.count < 1 { return false }
        case .des:
            if desDecryptionKey?.isEmpty ?? true { return false }
            if desDecryptionKey!.count != 8 { return false }
        default: break
        }

        return true
    }

    func hillEncBinding(row: Int, col: Int) -> Binding<String> {
        Binding<String>(
            get: { hillEncryptionKey[row][col].map { String($0) } ?? "" },
            set: { hillEncryptionKey[row][col] = Int($0) }
        )
    }

    func hillDecBinding(row: Int, col: Int) -> Binding<String> {
        Binding<String>(
            get: { hillDecryptionKey[row][col].map { String($0) } ?? "" },
            set: { hillDecryptionKey[row][col] = Int($0) }
        )
    }
}
