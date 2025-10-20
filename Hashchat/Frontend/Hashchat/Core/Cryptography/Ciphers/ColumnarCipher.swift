//
//  ColumnarCipher.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 20.10.2025.
//

struct ColumnarCipher: CipherProtocol {
    let key: String
    func encrypt(_ text: String) -> String { Crypto.columnarEncrypt(text, key: key) }
    func decrypt(_ text: String) -> String { Crypto.columnarDecrypt(text, key: key) }
}
