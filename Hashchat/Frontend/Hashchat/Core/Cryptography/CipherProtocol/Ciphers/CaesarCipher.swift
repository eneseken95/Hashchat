//
//  CaesarCipher.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 20.10.2025.
//

struct CaesarCipher: CipherProtocol {
    let shift: Int
    func encrypt(_ text: String) -> String { Crypto.caesarEncrypt(text, shift: shift) }
    func decrypt(_ text: String) -> String { Crypto.caesarDecrypt(text, shift: shift) }
}
