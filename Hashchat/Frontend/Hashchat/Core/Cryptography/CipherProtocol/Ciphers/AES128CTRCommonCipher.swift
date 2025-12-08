//
//  AES128CTRCommonCipher.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 8.12.2025.
//

import CommonCrypto
import Foundation

struct AES128CTRCommonCipher: CipherProtocol {
    private let key: Data

    init(key: String) {
        self.key = Data(AES128CTRCore._deriveKey16(key))
    }

    func encrypt(_ text: String) -> String {
        let data = text.data(using: .utf8)!
        let iv = Data(AES128CTRCore._makeIV16())
        let cipher = cryptCC(data: data, key: key, iv: iv)
        return AES128CTRCore._pack(iv: Array(iv), cipher: Array(cipher))
    }

    func decrypt(_ packed: String) -> String {
        do {
            let (iv, cipher) = try AES128CTRCore._unpack(packed, ivLen: 16)
            let plain = cryptCC(data: Data(cipher), key: key, iv: Data(iv))
            return String(data: plain, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }

    private func cryptCC(data: Data, key: Data, iv: Data) -> Data {
        var cryptor: CCCryptorRef?

        let status = CCCryptorCreateWithMode(
            CCOperation(kCCEncrypt),
            CCMode(kCCModeCTR),
            CCAlgorithm(kCCAlgorithmAES128),
            CCPadding(ccNoPadding),
            (iv as NSData).bytes,
            (key as NSData).bytes,
            key.count,
            nil, 0, 0, CCModeOptions(),
            &cryptor
        )

        guard status == kCCSuccess, let cryptorRef = cryptor else {
            return Data()
        }

        var outBytes = [UInt8](repeating: 0, count: data.count)
        var moved = 0

        let updateStatus = data.withUnsafeBytes { dataPtr in
            CCCryptorUpdate(
                cryptorRef,
                dataPtr.baseAddress,
                data.count,
                &outBytes,
                outBytes.count,
                &moved
            )
        }

        CCCryptorRelease(cryptorRef)

        guard updateStatus == kCCSuccess else {
            return Data()
        }

        return Data(bytes: outBytes, count: moved)
    }
}
