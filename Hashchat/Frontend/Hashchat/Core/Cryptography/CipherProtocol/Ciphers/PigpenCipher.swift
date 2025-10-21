//
//  PigpenCipher.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 20.10.2025.
//

struct PigpenCipher: CipherProtocol {
    func encrypt(_ text: String) -> String { Crypto.pigpenEncrypt(text) }
    func decrypt(_ text: String) -> String { Crypto.pigpenDecrypt(text) }
}
