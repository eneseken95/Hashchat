//
//  DESCBCCipher.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 8.12.2025.
//

import CommonCrypto
import Foundation

struct DESCBCCipher: CipherProtocol {
    private let key: Data

    init(key: String) {
        self.key = Data(DESCore._deriveKey8(key))
    }

    func encrypt(_ text: String) -> String {
        let data = text.data(using: .utf8)!
        let iv = Data(DESCore._makeIV8())
        let cipher = cryptCC(
            data: data,
            key: key,
            iv: iv,
            op: CCOperation(kCCEncrypt)
        )
        return DESCore._pack(iv: Array(iv), cipher: Array(cipher))
    }

    func decrypt(_ packed: String) -> String {
        do {
            let (iv, cipher) = try DESCore._unpack(packed, ivLen: 8)
            let plain = cryptCC(
                data: Data(cipher),
                key: key,
                iv: Data(iv),
                op: CCOperation(kCCDecrypt)
            )
            return String(data: plain, encoding: .utf8) ?? ""
        } catch {
            return ""
        }
    }

    private func cryptCC(data: Data, key: Data, iv: Data, op: CCOperation) -> Data {
        let outLength = data.count + kCCBlockSizeDES
        var outBytes = [UInt8](repeating: 0, count: outLength)
        var bytesMoved = 0

        let status = key.withUnsafeBytes { keyPtr in
            iv.withUnsafeBytes { ivPtr in
                data.withUnsafeBytes { dataPtr in
                    CCCrypt(
                        op,
                        CCAlgorithm(kCCAlgorithmDES),
                        CCOptions(kCCOptionPKCS7Padding),
                        keyPtr.baseAddress,
                        kCCKeySizeDES,
                        ivPtr.baseAddress,
                        dataPtr.baseAddress,
                        data.count,
                        &outBytes,
                        outLength,
                        &bytesMoved
                    )
                }
            }
        }

        guard status == kCCSuccess else {
            return Data()
        }

        return Data(bytes: outBytes, count: bytesMoved)
    }
}
