//
//  RSACipher.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 11.12.2025.
//

struct RSACipher: CipherProtocol {
    var recipientPublicKey: String?

    func encrypt(_ text: String) -> String {
        guard let recipientKey = recipientPublicKey else {
            print("RSACipher: No recipient public key - cannot encrypt!")
            return "[ERROR: Recipient key not available]"
        }

        return Crypto.RSA.shared.encrypt(text, withPublicKey: recipientKey)
    }

    func decrypt(_ text: String) -> String {
        Crypto.RSA.shared.decrypt(text)
    }
}
