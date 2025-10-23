//
//  EuclidCipher.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 23.10.2025.
//

struct EuclidCipher: CipherProtocol {
    let key: Int

    func encrypt(_ text: String) -> String {
        Crypto.euclidEncrypt(text, key: key)
    }

    func decrypt(_ text: String) -> String {
        Crypto.euclidDecrypt(text, key: key)
    }
}
