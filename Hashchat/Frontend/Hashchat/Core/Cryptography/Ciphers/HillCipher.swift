//
//  HillCipher.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 20.10.2025.
//

struct HillCipher: CipherProtocol {
    let key: [[Int]]
    func encrypt(_ text: String) -> String { (try? Crypto.hillEncrypt(text, key: key)) ?? text }
    func decrypt(_ text: String) -> String { (try? Crypto.hillDecrypt(text, key: key)) ?? text }
}
