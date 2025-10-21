//
//  PolybiusCipher.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 20.10.2025.
//

struct PolybiusCipher: CipherProtocol {
    func encrypt(_ text: String) -> String { Crypto.polybiusEncrypt(text) }
    func decrypt(_ text: String) -> String { Crypto.polybiusDecrypt(text) }
}
