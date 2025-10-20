//
//  VigenereCipher.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 20.10.2025.
//

struct VigenereCipher: CipherProtocol {
    let key: String
    func encrypt(_ text: String) -> String { Crypto.vigenereEncrypt(text, key: key) }
    func decrypt(_ text: String) -> String { Crypto.vigenereDecrypt(text, key: key) }
}
