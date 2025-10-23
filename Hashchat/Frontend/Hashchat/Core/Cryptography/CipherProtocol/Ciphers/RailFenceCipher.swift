//
//  RailFenceCipher.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 23.10.2025.
//

struct RailFenceCipher: CipherProtocol {
    let rails: Int

    func encrypt(_ text: String) -> String {
        Crypto.railFenceEncrypt(text, rails: rails)
    }

    func decrypt(_ text: String) -> String {
        Crypto.railFenceDecrypt(text, rails: rails)
    }
}
