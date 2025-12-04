//
//  DESCore.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 3.12.2025.
//

import Foundation

enum DESPureError: Error {
    case badKey, badIV, badPadding, badPacket
}

struct DESCore {
    static func encryptCBC(_ plaintext: [UInt8], key8: [UInt8], iv8: [UInt8]) throws -> [UInt8] {
        guard key8.count == 8 else {
            throw DESPureError.badKey
        }
        guard iv8.count == 8 else {
            throw DESPureError.badIV
        }
        let subkeys = makeSubkeys(key: key8)
        let padded = pkcs7Pad(plaintext, blockSize: 8)
        var prev = iv8
        var out: [UInt8] = []
        out.reserveCapacity(padded.count)
        
        for start in stride(from: 0, to: padded.count, by: 8) {
            var block = Array(padded[start ..< start + 8])
            for i in 0 ..< 8 {
                block[i] ^= prev[i]
            }
            let enc = cryptBlock(block, subkeys: subkeys, decrypt: false)
            out.append(contentsOf: enc)
            prev = enc
        }
        return out
    }

    static func decryptCBC(_ ciphertext: [UInt8], key8: [UInt8], iv8: [UInt8]) throws -> [UInt8] {
        guard key8.count == 8 else {
            throw DESPureError.badKey
        }
        guard iv8.count == 8 else {
            throw DESPureError.badIV
        }
        guard ciphertext.count % 8 == 0 else {
            throw DESPureError.badPacket
        }
        
        let subkeys = makeSubkeys(key: key8)
        var prev = iv8
        var out: [UInt8] = []
        out.reserveCapacity(ciphertext.count)
        
        for start in stride(from: 0, to: ciphertext.count, by: 8) {
            let block = Array(ciphertext[start ..< start + 8])
            let dec = cryptBlock(block, subkeys: subkeys, decrypt: true)
            var plain = dec
            
            for i in 0 ..< 8 {
                plain[i] ^= prev[i]
            }
            out.append(contentsOf: plain)
            prev = block
        }
        return try pkcs7Unpad(out, blockSize: 8)
    }

    private static func cryptBlock(_ block8: [UInt8], subkeys: [UInt64], decrypt: Bool) -> [UInt8] {
        var x = bytesToU64(block8)
        x = permute(x, IP, inputBits: 64)
        var L = UInt32((x >> 32) & 0xFFFFFFFF)
        var R = UInt32(x & 0xFFFFFFFF)
        
        for round in 0 ..< 16 {
            let k = decrypt ? subkeys[15 - round] : subkeys[round]
            let f = feistel(R, subkey: k)
            let newL = R
            let newR = L ^ f
            L = newL
            R = newR
        }
        
        let preoutput = (UInt64(R) << 32) | UInt64(L)
        let y = permute(preoutput, FP, inputBits: 64)
        return u64ToBytes(y)
    }

    private static func feistel(_ r: UInt32, subkey: UInt64) -> UInt32 {
        let expanded = permute(UInt64(r), E, inputBits: 32)
        let x = expanded ^ subkey
        var sOut: UInt32 = 0
        
        for i in 0 ..< 8 {
            let shift = UInt64((7 - i) * 6)
            let six = Int((x >> shift) & 0x3F)
            let row = ((six & 0x20) >> 4) | (six & 0x01)
            let col = (six >> 1) & 0x0F
            let val = SBOX[i][row][col]
            sOut = (sOut << 4) | UInt32(val)
        }
        let p = permute(UInt64(sOut), P, inputBits: 32)
        return UInt32(p & 0xFFFFFFFF)
    }

    private static func makeSubkeys(key: [UInt8]) -> [UInt64] {
        let k64 = bytesToU64(key)
        let perm56 = permute(k64, PC1, inputBits: 64)
        var C = UInt32((perm56 >> 28) & 0x0FFFFFFF)
        var D = UInt32(perm56 & 0x0FFFFFFF)
        var subkeys: [UInt64] = []
        subkeys.reserveCapacity(16)
        
        for round in 0 ..< 16 {
            C = leftRotate28(C, by: SHIFTS[round])
            D = leftRotate28(D, by: SHIFTS[round])
            let cd = (UInt64(C) << 28) | UInt64(D)
            let k48 = permute(cd, PC2, inputBits: 56)
            subkeys.append(k48)
        }
        return subkeys
    }

    private static func leftRotate28(_ x: UInt32, by n: Int) -> UInt32 {
        let m: UInt32 = 0x0FFFFFFF
        let v = x & m
        return ((v << n) | (v >> (28 - n))) & m
    }

    private static func permute(_ input: UInt64, _ table: [Int], inputBits: Int) -> UInt64 {
        var out: UInt64 = 0
        
        for pos in table {
            let bit = (input >> UInt64(inputBits - pos)) & 1
            out = (out << 1) | bit
        }
        return out
    }

    private static func pkcs7Pad(_ bytes: [UInt8], blockSize: Int) -> [UInt8] {
        let pad = blockSize - (bytes.count % blockSize)
        return bytes + [UInt8](repeating: UInt8(pad), count: pad)
    }

    private static func pkcs7Unpad(_ bytes: [UInt8], blockSize: Int) throws -> [UInt8] {
        guard let last = bytes.last else {
            throw DESPureError.badPadding
        }
        
        let pad = Int(last)
        guard pad > 0, pad <= blockSize, bytes.count >= pad else {
            throw DESPureError.badPadding
        }
        
        if bytes.suffix(pad).contains(where: { $0 != last }) {
            throw DESPureError.badPadding
        }
        return Array(bytes.dropLast(pad))
    }

    private static func bytesToU64(_ b: [UInt8]) -> UInt64 {
        var x: UInt64 = 0
        for v in b {
            x = (x << 8) | UInt64(v)
        }
        return x
    }

    private static func u64ToBytes(_ x: UInt64) -> [UInt8] {
        (0 ..< 8).map {
            i in UInt8((x >> UInt64((7 - i) * 8)) & 0xFF)
        }
    }

    private static let SHIFTS = [1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1]

    private static let IP: [Int] = [
        58, 50, 42, 34, 26, 18, 10, 2, 60, 52, 44, 36, 28, 20, 12, 4,
        62, 54, 46, 38, 30, 22, 14, 6, 64, 56, 48, 40, 32, 24, 16, 8,
        57, 49, 41, 33, 25, 17, 9, 1, 59, 51, 43, 35, 27, 19, 11, 3,
        61, 53, 45, 37, 29, 21, 13, 5, 63, 55, 47, 39, 31, 23, 15, 7,
    ]

    private static let FP: [Int] = [
        40, 8, 48, 16, 56, 24, 64, 32, 39, 7, 47, 15, 55, 23, 63, 31,
        38, 6, 46, 14, 54, 22, 62, 30, 37, 5, 45, 13, 53, 21, 61, 29,
        36, 4, 44, 12, 52, 20, 60, 28, 35, 3, 43, 11, 51, 19, 59, 27,
        34, 2, 42, 10, 50, 18, 58, 26, 33, 1, 41, 9, 49, 17, 57, 25,
    ]

    private static let E: [Int] = [
        32, 1, 2, 3, 4, 5, 4, 5, 6, 7, 8, 9, 8, 9, 10, 11, 12, 13,
        12, 13, 14, 15, 16, 17, 16, 17, 18, 19, 20, 21, 20, 21, 22, 23, 24, 25,
        24, 25, 26, 27, 28, 29, 28, 29, 30, 31, 32, 1,
    ]

    private static let P: [Int] = [
        16, 7, 20, 21, 29, 12, 28, 17, 1, 15, 23, 26, 5, 18, 31, 10,
        2, 8, 24, 14, 32, 27, 3, 9, 19, 13, 30, 6, 22, 11, 4, 25,
    ]

    private static let PC1: [Int] = [
        57, 49, 41, 33, 25, 17, 9, 1, 58, 50, 42, 34, 26, 18, 10, 2,
        59, 51, 43, 35, 27, 19, 11, 3, 60, 52, 44, 36, 63, 55, 47, 39,
        31, 23, 15, 7, 62, 54, 46, 38, 30, 22, 14, 6, 61, 53, 45, 37,
        29, 21, 13, 5, 28, 20, 12, 4,
    ]

    private static let PC2: [Int] = [
        14, 17, 11, 24, 1, 5, 3, 28, 15, 6, 21, 10, 23, 19, 12, 4,
        26, 8, 16, 7, 27, 20, 13, 2, 41, 52, 31, 37, 47, 55, 30, 40,
        51, 45, 33, 48, 44, 49, 39, 56, 34, 53, 46, 42, 50, 36, 29, 32,
    ]

    private static let SBOX: [[[UInt8]]] = [
        [
            [14, 4, 13, 1, 2, 15, 11, 8, 3, 10, 6, 12, 5, 9, 0, 7],
            [0, 15, 7, 4, 14, 2, 13, 1, 10, 6, 12, 11, 9, 5, 3, 8],
            [4, 1, 14, 8, 13, 6, 2, 11, 15, 12, 9, 7, 3, 10, 5, 0],
            [15, 12, 8, 2, 4, 9, 1, 7, 5, 11, 3, 14, 10, 0, 6, 13],
        ],
        [
            [15, 1, 8, 14, 6, 11, 3, 4, 9, 7, 2, 13, 12, 0, 5, 10],
            [3, 13, 4, 7, 15, 2, 8, 14, 12, 0, 1, 10, 6, 9, 11, 5],
            [0, 14, 7, 11, 10, 4, 13, 1, 5, 8, 12, 6, 9, 3, 2, 15],
            [13, 8, 10, 1, 3, 15, 4, 2, 11, 6, 7, 12, 0, 5, 14, 9],
        ],
        [
            [10, 0, 9, 14, 6, 3, 15, 5, 1, 13, 12, 7, 11, 4, 2, 8],
            [13, 7, 0, 9, 3, 4, 6, 10, 2, 8, 5, 14, 12, 11, 15, 1],
            [13, 6, 4, 9, 8, 15, 3, 0, 11, 1, 2, 12, 5, 10, 14, 7],
            [1, 10, 13, 0, 6, 9, 8, 7, 4, 15, 14, 3, 11, 5, 2, 12],
        ],
        [
            [7, 13, 14, 3, 0, 6, 9, 10, 1, 2, 8, 5, 11, 12, 4, 15],
            [13, 8, 11, 5, 6, 15, 0, 3, 4, 7, 2, 12, 1, 10, 14, 9],
            [10, 6, 9, 0, 12, 11, 7, 13, 15, 1, 3, 14, 5, 2, 8, 4],
            [3, 15, 0, 6, 10, 1, 13, 8, 9, 4, 5, 11, 12, 7, 2, 14],
        ],
        [
            [2, 12, 4, 1, 7, 10, 11, 6, 8, 5, 3, 15, 13, 0, 14, 9],
            [14, 11, 2, 12, 4, 7, 13, 1, 5, 0, 15, 10, 3, 9, 8, 6],
            [4, 2, 1, 11, 10, 13, 7, 8, 15, 9, 12, 5, 6, 3, 0, 14],
            [11, 8, 12, 7, 1, 14, 2, 13, 6, 15, 0, 9, 10, 4, 5, 3],
        ],
        [
            [12, 1, 10, 15, 9, 2, 6, 8, 0, 13, 3, 4, 14, 7, 5, 11],
            [10, 15, 4, 2, 7, 12, 9, 5, 6, 1, 13, 14, 0, 11, 3, 8],
            [9, 14, 15, 5, 2, 8, 12, 3, 7, 0, 4, 10, 1, 13, 11, 6],
            [4, 3, 2, 12, 9, 5, 15, 10, 11, 14, 1, 7, 6, 0, 8, 13],
        ],
        [
            [4, 11, 2, 14, 15, 0, 8, 13, 3, 12, 9, 7, 5, 10, 6, 1],
            [13, 0, 11, 7, 4, 9, 1, 10, 14, 3, 5, 12, 2, 15, 8, 6],
            [1, 4, 11, 13, 12, 3, 7, 14, 10, 15, 6, 8, 0, 5, 9, 2],
            [6, 11, 13, 8, 1, 4, 10, 7, 9, 5, 0, 15, 14, 2, 3, 12],
        ],
        [
            [13, 2, 8, 4, 6, 15, 11, 1, 10, 9, 3, 14, 5, 0, 12, 7],
            [1, 15, 13, 8, 10, 3, 7, 4, 12, 5, 6, 11, 0, 14, 9, 2],
            [7, 11, 4, 1, 9, 12, 14, 2, 0, 6, 10, 13, 15, 3, 5, 8],
            [2, 1, 14, 7, 4, 10, 8, 13, 15, 12, 9, 0, 3, 5, 6, 11],
        ],
    ]
}

extension DESCore {
    static func _deriveKey8(_ passphrase: String) -> [UInt8] {
        let src = Array(passphrase.utf8)
        
        if src.isEmpty {
            return [UInt8](repeating: 0, count: 8)
        }
        return (0 ..< 8).map { src[$0 % src.count] }
    }

    static func _makeIV8() -> [UInt8] {
        var t = UInt64(Date().timeIntervalSince1970 * 1000)
        t ^= (t << 13); t ^= (t >> 7); t ^= (t << 17)
        return (0 ..< 8).map {
            i in UInt8((t >> UInt64((7 - i) * 8)) & 0xFF)
        }
    }

    static func _pack(iv: [UInt8], cipher: [UInt8]) -> String {
        var d = Data(iv)
        d.append(contentsOf: cipher)
        return d.base64EncodedString()
    }

    static func _unpack(_ b64: String, ivLen: Int) throws -> (iv: [UInt8], cipher: [UInt8]) {
        guard let data = Data(base64Encoded: b64) else {
            throw DESPureError.badPacket
        }
        
        let bytes = [UInt8](data)
        guard bytes.count >= ivLen else {
            throw DESPureError.badPacket
        }
        return (Array(bytes[0 ..< ivLen]), Array(bytes[ivLen ..< bytes.count]))
    }
}
