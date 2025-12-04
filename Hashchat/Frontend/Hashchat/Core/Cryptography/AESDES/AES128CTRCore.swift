//
//  AES128CTRCore.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 3.12.2025.
//

import Foundation

enum PureCryptoError: Error {
    case badKey, badPacket
}

fileprivate enum Derive {
    static func keyBytes(from passphrase: String, count: Int) -> [UInt8] {
        let src = Array(passphrase.utf8)
        
        if src.isEmpty {
            return [UInt8](repeating: 0, count: count)
        }
        
        var out: [UInt8] = []
        out.reserveCapacity(count)
        var i = 0
        
        while out.count < count {
            out.append(src[i % src.count])
            i += 1
        }
        return out
    }

    static func makeIV16() -> [UInt8] {
        var t = UInt64(Date().timeIntervalSince1970 * 1000)
        Counter.next(&t)
        var out = [UInt8](repeating: 0, count: 16)
        
        for i in 0 ..< 8 {
            out[i] = UInt8((t >> UInt64((7 - i) * 8)) & 0xFF)
        }
        
        for i in 8 ..< 16 {
            out[i] = out[i - 8] ^ UInt8((i * 31) & 0xFF)
        }
        return out
    }

    private enum Counter {
        private static var c: UInt64 = 0
        static func next(_ t: inout UInt64) {
            c &+= 1
            t ^= (c &* 0x9E3779B97F4A7C15)
        }
    }
}

struct AES128CTRCore {
    private let roundKeys: [UInt8]

    init(key16: [UInt8]) throws {
        guard key16.count == 16 else {
            throw PureCryptoError.badKey
        }
        roundKeys = Self.expandKey128(key16)
    }

    func crypt(_ input: [UInt8], iv16: [UInt8]) throws -> [UInt8] {
        guard iv16.count == 16 else {
            throw PureCryptoError.badKey
        }
        var counter = iv16
        var output = [UInt8](repeating: 0, count: input.count)
        var offset = 0
        
        while offset < input.count {
            let ks = Self.encryptBlock(counter, roundKeys: roundKeys)
            let n = min(16, input.count - offset)
            for i in 0 ..< n {
                output[offset + i] = input[offset + i] ^ ks[i]
            }
            
            Self.incrementCounter(&counter)
            offset += n
        }
        return output
    }

    private static let sbox: [UInt8] = [
        0x63, 0x7C, 0x77, 0x7B, 0xF2, 0x6B, 0x6F, 0xC5, 0x30, 0x01, 0x67, 0x2B, 0xFE, 0xD7, 0xAB, 0x76,
        0xCA, 0x82, 0xC9, 0x7D, 0xFA, 0x59, 0x47, 0xF0, 0xAD, 0xD4, 0xA2, 0xAF, 0x9C, 0xA4, 0x72, 0xC0,
        0xB7, 0xFD, 0x93, 0x26, 0x36, 0x3F, 0xF7, 0xCC, 0x34, 0xA5, 0xE5, 0xF1, 0x71, 0xD8, 0x31, 0x15,
        0x04, 0xC7, 0x23, 0xC3, 0x18, 0x96, 0x05, 0x9A, 0x07, 0x12, 0x80, 0xE2, 0xEB, 0x27, 0xB2, 0x75,
        0x09, 0x83, 0x2C, 0x1A, 0x1B, 0x6E, 0x5A, 0xA0, 0x52, 0x3B, 0xD6, 0xB3, 0x29, 0xE3, 0x2F, 0x84,
        0x53, 0xD1, 0x00, 0xED, 0x20, 0xFC, 0xB1, 0x5B, 0x6A, 0xCB, 0xBE, 0x39, 0x4A, 0x4C, 0x58, 0xCF,
        0xD0, 0xEF, 0xAA, 0xFB, 0x43, 0x4D, 0x33, 0x85, 0x45, 0xF9, 0x02, 0x7F, 0x50, 0x3C, 0x9F, 0xA8,
        0x51, 0xA3, 0x40, 0x8F, 0x92, 0x9D, 0x38, 0xF5, 0xBC, 0xB6, 0xDA, 0x21, 0x10, 0xFF, 0xF3, 0xD2,
        0xCD, 0x0C, 0x13, 0xEC, 0x5F, 0x97, 0x44, 0x17, 0xC4, 0xA7, 0x7E, 0x3D, 0x64, 0x5D, 0x19, 0x73,
        0x60, 0x81, 0x4F, 0xDC, 0x22, 0x2A, 0x90, 0x88, 0x46, 0xEE, 0xB8, 0x14, 0xDE, 0x5E, 0x0B, 0xDB,
        0xE0, 0x32, 0x3A, 0x0A, 0x49, 0x06, 0x24, 0x5C, 0xC2, 0xD3, 0xAC, 0x62, 0x91, 0x95, 0xE4, 0x79,
        0xE7, 0xC8, 0x37, 0x6D, 0x8D, 0xD5, 0x4E, 0xA9, 0x6C, 0x56, 0xF4, 0xEA, 0x65, 0x7A, 0xAE, 0x08,
        0xBA, 0x78, 0x25, 0x2E, 0x1C, 0xA6, 0xB4, 0xC6, 0xE8, 0xDD, 0x74, 0x1F, 0x4B, 0xBD, 0x8B, 0x8A,
        0x70, 0x3E, 0xB5, 0x66, 0x48, 0x03, 0xF6, 0x0E, 0x61, 0x35, 0x57, 0xB9, 0x86, 0xC1, 0x1D, 0x9E,
        0xE1, 0xF8, 0x98, 0x11, 0x69, 0xD9, 0x8E, 0x94, 0x9B, 0x1E, 0x87, 0xE9, 0xCE, 0x55, 0x28, 0xDF,
        0x8C, 0xA1, 0x89, 0x0D, 0xBF, 0xE6, 0x42, 0x68, 0x41, 0x99, 0x2D, 0x0F, 0xB0, 0x54, 0xBB, 0x16,
    ]

    private static let rcon: [UInt8] = [0x00, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80, 0x1B, 0x36]

    private static func expandKey128(_ key: [UInt8]) -> [UInt8] {
        var expanded = [UInt8](repeating: 0, count: 176)
        expanded[0 ..< 16] = key[0 ..< 16]
        var bytesGenerated = 16
        var rconIter = 1
        var temp = [UInt8](repeating: 0, count: 4)

        while bytesGenerated < 176 {
            for i in 0 ..< 4 {
                temp[i] = expanded[bytesGenerated - 4 + i]
            }
            if bytesGenerated % 16 == 0 {
                temp = [temp[1], temp[2], temp[3], temp[0]]
                for i in 0 ..< 4 {
                    temp[i] = sbox[Int(temp[i])]
                }
                temp[0] ^= rcon[rconIter]
                rconIter += 1
            }
            for i in 0 ..< 4 {
                expanded[bytesGenerated] = expanded[bytesGenerated - 16] ^ temp[i]
                bytesGenerated += 1
            }
        }
        return expanded
    }

    private static func encryptBlock(_ input: [UInt8], roundKeys: [UInt8]) -> [UInt8] {
        var state = input
        addRoundKey(&state, roundKeys, 0)
        
        for round in 1 ... 9 {
            subBytes(&state)
            shiftRows(&state)
            mixColumns(&state)
            addRoundKey(&state, roundKeys, round)
        }
        subBytes(&state)
        shiftRows(&state)
        addRoundKey(&state, roundKeys, 10)
        return state
    }

    private static func addRoundKey(_ state: inout [UInt8], _ rk: [UInt8], _ round: Int) {
        let start = round * 16
        for i in 0 ..< 16 {
            state[i] ^= rk[start + i]
        }
    }

    private static func subBytes(_ state: inout [UInt8]) {
        for i in 0 ..< 16 {
            state[i] = sbox[Int(state[i])]
        }
    }

    private static func shiftRows(_ s: inout [UInt8]) {
        let t = s
        
        s[0] = t[0]; s[4] = t[4]; s[8] = t[8]; s[12] = t[12]
        s[1] = t[5]; s[5] = t[9]; s[9] = t[13]; s[13] = t[1]
        s[2] = t[10]; s[6] = t[14]; s[10] = t[2]; s[14] = t[6]
        s[3] = t[15]; s[7] = t[3]; s[11] = t[7]; s[15] = t[11]
    }

    private static func xtime(_ x: UInt8) -> UInt8 {
        let shifted = UInt16(x) << 1
        let mask = (x & 0x80) != 0 ? 0x1B : 0x00
        return UInt8((shifted & 0xFF) ^ UInt16(mask))
    }

    private static func mul2(_ x: UInt8) -> UInt8 {
        xtime(x)
    }
    
    private static func mul3(_ x: UInt8) -> UInt8 {
        xtime(x) ^ x
    }

    private static func mixColumns(_ s: inout [UInt8]) {
        for c in 0 ..< 4 {
            let i = c * 4
            let a0 = s[i + 0], a1 = s[i + 1], a2 = s[i + 2], a3 = s[i + 3]
            
            s[i + 0] = mul2(a0) ^ mul3(a1) ^ a2 ^ a3
            s[i + 1] = a0 ^ mul2(a1) ^ mul3(a2) ^ a3
            s[i + 2] = a0 ^ a1 ^ mul2(a2) ^ mul3(a3)
            s[i + 3] = mul3(a0) ^ a1 ^ a2 ^ mul2(a3)
        }
    }

    private static func incrementCounter(_ counter: inout [UInt8]) {
        var carry: UInt16 = 1
        
        for idx in stride(from: 15, through: 12, by: -1) {
            let sum = UInt16(counter[idx]) + carry
            counter[idx] = UInt8(sum & 0xFF)
            carry = sum >> 8
        }
    }
}

fileprivate enum Packet {
    static func pack(iv: [UInt8], cipher: [UInt8]) -> String {
        var d = Data(iv)
        d.append(contentsOf: cipher)
        return d.base64EncodedString()
    }

    static func unpack(_ b64: String, ivLen: Int) throws -> (iv: [UInt8], cipher: [UInt8]) {
        guard let data = Data(base64Encoded: b64) else {
            throw PureCryptoError.badPacket
        }
        let bytes = [UInt8](data)
        
        guard bytes.count >= ivLen else {
            throw PureCryptoError.badPacket
        }
        
        return (Array(bytes[0 ..< ivLen]), Array(bytes[ivLen ..< bytes.count]))
    }
}

extension AES128CTRCore {
    static func _deriveKey16(_ passphrase: String) -> [UInt8] {
        Derive.keyBytes(from: passphrase, count: 16)
    }
    static func _makeIV16() -> [UInt8] {
        Derive.makeIV16()
    }
    static func _pack(iv: [UInt8], cipher: [UInt8]) -> String {
        Packet.pack(iv: iv, cipher: cipher)
    }
    static func _unpack(_ b64: String, ivLen: Int) throws -> (iv: [UInt8], cipher: [UInt8]) {
        try Packet.unpack(b64, ivLen: ivLen)
    }
}
