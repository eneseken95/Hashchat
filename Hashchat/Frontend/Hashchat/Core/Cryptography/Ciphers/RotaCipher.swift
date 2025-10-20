//
//  RotaCipher.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 20.10.2025.
//

struct RotaCipher: CipherProtocol {
    func encrypt(_ text: String) -> String { Crypto.rotaEncrypt(text) }
    func decrypt(_ text: String) -> String { Crypto.rotaDecrypt(text) }
}
