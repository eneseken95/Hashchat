//
//  CryptoBenchmark.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 8.12.2025.
//

import Foundation

func benchmark(_ title: String, block: () -> Void) {
    let start = CFAbsoluteTimeGetCurrent()
    block()
    let duration = (CFAbsoluteTimeGetCurrent() - start) * 1000
    print("Duration \(title): \(String(format: "%.3f", duration)) ms")
}

func runCryptoBenchmark() {
    print("HASHCHAT BENCHMARK")

    let text = String(repeating: "Hello Hashchat Encryption ", count: 2000)
    let key = "mysecretkey"

    print("AES-128 CTR")
    let pureAES = try! AES128CTRCore(key16: AES128CTRCore._deriveKey16(key))

    benchmark("PURE AES ENCRYPT") {
        _ = try! pureAES.crypt(Array(text.utf8), iv16: AES128CTRCore._makeIV16())
    }

    let aesCC = AES128CTRCommonCipher(key: key)
    benchmark("CommonCrypto AES ENCRYPT") {
        _ = aesCC.encrypt(text)
    }

    print("\nDES CBC")
    let desKey = DESCore._deriveKey8(key)

    benchmark("PURE DES ENCRYPT") {
        _ = try! DESCore.encryptCBC(Array(text.utf8), key8: desKey, iv8: DESCore._makeIV8())
    }

    let desCC = DESCBCCipher(key: key)
    benchmark("CommonCrypto DES ENCRYPT") {
        _ = desCC.encrypt(text)
    }
}
