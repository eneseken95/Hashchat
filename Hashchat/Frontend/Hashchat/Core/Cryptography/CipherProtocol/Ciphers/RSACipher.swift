//
//  RSACipher.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 11.12.2025.
//

struct RSACipher: CipherProtocol {
    func encrypt(_ text: String) -> String {
        Crypto.RSA.shared.encrypt(text)
    }

    func decrypt(_ text: String) -> String {
        Crypto.RSA.shared.decrypt(text)
    }
}
