//
//  DESCipher.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 3.12.2025.
//

import Foundation

struct DESCipher: CipherProtocol {
    let key: String

    func encrypt(_ text: String) -> String {
        return Crypto.desEncrypt(text, key: key)
    }

    func decrypt(_ text: String) -> String {
        return Crypto.desDecrypt(text, key: key)
    }
}
