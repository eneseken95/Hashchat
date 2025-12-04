//
//  AESCipher.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 3.12.2025.
//

import Foundation

struct AESCipher: CipherProtocol {
    let key: String

    func encrypt(_ text: String) -> String {
        return Crypto.aesEncrypt(text, key: key)
    }

    func decrypt(_ text: String) -> String {
        return Crypto.aesDecrypt(text, key: key)
    }
}
