//
//  Crypto.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 12.10.2025.
//

import Foundation

enum CipherError: Error {
    case invalidKey
}

final class Crypto {
    // MARK: caesar and vigenere

    static func caesarEncrypt(_ text: String, shift: Int) -> String {
        return caesarShift(text, shift: shift)
    }

    static func caesarDecrypt(_ text: String, shift: Int) -> String {
        return caesarShift(text, shift: -shift)
    }

    private static func caesarShift(_ text: String, shift: Int) -> String {
        var result = ""
        for scalar in text.unicodeScalars {
            let value = scalar.value
            if (65 ... 90).contains(value) {
                let shifted = ((Int(value) - 65 + shift + 26) % 26) + 65
                if let unicodeScalar = UnicodeScalar(shifted) {
                    result += String(unicodeScalar)
                }
            } else if (97 ... 122).contains(value) {
                let shifted = ((Int(value) - 97 + shift + 26) % 26) + 97
                if let unicodeScalar = UnicodeScalar(shifted) {
                    result += String(unicodeScalar)
                }
            } else {
                result += String(scalar)
            }
        }
        return result
    }

    static func vigenereEncrypt(_ text: String, key: String) -> String {
        return vigenereShift(text, key: key, encrypting: true)
    }

    static func vigenereDecrypt(_ text: String, key: String) -> String {
        return vigenereShift(text, key: key, encrypting: false)
    }

    private static func vigenereShift(_ text: String, key: String, encrypting: Bool) -> String {
        let keyChars = Array(key.lowercased())
        var result = ""
        var keyIndex = 0

        for char in text {
            if let ascii = char.asciiValue, char.isLetter {
                if let keyAscii = keyChars[keyIndex % keyChars.count].asciiValue {
                    let shift = Int(keyAscii - 97) * (encrypting ? 1 : -1)
                    let base = char.isUppercase ? 65 : 97
                    if let newScalar = UnicodeScalar((Int(ascii) - base + shift + 26) % 26 + base) {
                        result.append(Character(newScalar))
                    }
                    keyIndex += 1
                }
            } else {
                result.append(char)
            }
        }
        return result
    }

    static func encrypt(_ text: String, caesarShift: Int, vigenereKey: String) -> String {
        let caesarText = caesarEncrypt(text, shift: caesarShift)
        return vigenereEncrypt(caesarText, key: vigenereKey)
    }

    static func decrypt(_ text: String, caesarShift: Int, vigenereKey: String) -> String {
        let vigenereText = vigenereDecrypt(text, key: vigenereKey)
        return caesarDecrypt(vigenereText, shift: caesarShift)
    }

    // MARK: rota

    static func rotaEncrypt(_ text: String) -> String {
        return caesarShift(text, shift: 13)
    }

    static func rotaDecrypt(_ text: String) -> String {
        return caesarShift(text, shift: 13)
    }

    // MARK: columnar

    static func columnarEncrypt(_ text: String, key: String) -> String {
        let cleanText = text.replacingOccurrences(of: " ", with: "")
        let numCols = key.count
        let numRows = (cleanText.count + numCols - 1) / numCols

        var grid = Array(repeating: Array(repeating: "X", count: numCols), count: numRows)
        var index = cleanText.startIndex
        for r in 0 ..< numRows {
            for c in 0 ..< numCols {
                if index < cleanText.endIndex {
                    grid[r][c] = String(cleanText[index])
                    index = cleanText.index(after: index)
                }
            }
        }

        let keyUpper = key.uppercased()
        let keyOrder = keyUpper.enumerated().sorted { $0.element < $1.element }.map { $0.offset }

        var cipher = ""
        for col in keyOrder {
            for row in 0 ..< numRows {
                cipher += grid[row][col]
            }
        }
        return cipher
    }

    static func columnarDecrypt(_ text: String, key: String) -> String {
        let numCols = key.count
        let numRows = (text.count + numCols - 1) / numCols

        var grid = Array(repeating: Array(repeating: "X", count: numCols), count: numRows)

        let keyUpper = key.uppercased()
        let keyOrder = keyUpper.enumerated().sorted { $0.element < $1.element }.map { $0.offset }

        var index = text.startIndex
        for col in keyOrder {
            for row in 0 ..< numRows {
                if index < text.endIndex {
                    grid[row][col] = String(text[index])
                    index = text.index(after: index)
                }
            }
        }

        var plain = ""
        for r in 0 ..< numRows {
            for c in 0 ..< numCols {
                let char = grid[r][c]
                if char != "X" {
                    plain += char
                }
            }
        }

        return plain
    }

    // MARK: polybius

    static let polybiusSquare: [Character: String] = [
        "A": "11", "B": "12", "C": "13", "D": "14", "E": "15",
        "F": "21", "G": "22", "H": "23", "I": "24", "J": "24", "K": "25",
        "L": "31", "M": "32", "N": "33", "O": "34", "P": "35",
        "Q": "41", "R": "42", "S": "43", "T": "44", "U": "45",
        "V": "51", "W": "52", "X": "53", "Y": "54", "Z": "55",
    ]

    static func polybiusEncrypt(_ text: String) -> String {
        var cipher = ""
        for char in text.uppercased() {
            if let code = polybiusSquare[char] {
                cipher += code
            } else {
                cipher += String(char)
            }
        }
        return cipher
    }

    static func polybiusDecrypt(_ text: String) -> String {
        var plain = ""
        var i = text.startIndex
        while i < text.endIndex {
            if i < text.index(before: text.endIndex), let number = Int(String(text[i ... text.index(i, offsetBy: 1)])) {
                if let letter = polybiusSquare.first(where: { $0.value == String(number) })?.key {
                    plain.append(letter)
                    i = text.index(i, offsetBy: 2)
                    continue
                }
            }
            plain.append(text[i])
            i = text.index(after: i)
        }
        return plain
    }

    // MARK: pigpen

    static let pigpenMap: [Character: String] = [
        "A": "\u{278A}", "B": "\u{278B}", "C": "\u{278C}", "D": "\u{278D}", "E": "\u{278E}",
        "F": "\u{278F}", "G": "\u{2790}", "H": "\u{2791}", "I": "\u{2792}", "J": "\u{2793}",
        "K": "\u{2794}", "L": "\u{2795}", "M": "\u{2796}", "N": "\u{2797}", "O": "\u{2798}",
        "P": "\u{2799}", "Q": "\u{279A}", "R": "\u{279B}", "S": "\u{279C}", "T": "\u{279D}",
        "U": "\u{279E}", "V": "\u{279F}", "W": "\u{27A0}", "X": "\u{27A1}", "Y": "\u{27A2}", "Z": "\u{27A3}",
    ]

    static func pigpenEncrypt(_ text: String) -> String {
        var cipher = ""
        for char in text.uppercased() {
            cipher += pigpenMap[char] ?? String(char)
        }
        return cipher
    }

    static func pigpenDecrypt(_ text: String) -> String {
        var plain = ""
        for char in text {
            if let original = pigpenMap.first(where: { $0.value == String(char) })?.key {
                plain.append(original)
            } else {
                plain.append(char)
            }
        }
        return plain
    }

    // MARK: hill

    static func hillEncrypt(_ text: String, key: [[Int]]) throws -> String {
        guard key.count == 2, key[0].count == 2, key[1].count == 2 else {
            throw CipherError.invalidKey
        }

        let cleanText = text.uppercased().filter { $0.isLetter }
        var paddedText = cleanText
        if paddedText.count % 2 != 0 {
            paddedText += "X"
        }

        var cipher = ""
        var i = 0
        while i < paddedText.count {
            let a = Int(paddedText[paddedText.index(paddedText.startIndex, offsetBy: i)].asciiValue! - 65)
            let b = Int(paddedText[paddedText.index(paddedText.startIndex, offsetBy: i + 1)].asciiValue! - 65)

            let c1 = (key[0][0] * a + key[0][1] * b) % 26
            let c2 = (key[1][0] * a + key[1][1] * b) % 26

            cipher.append(Character(UnicodeScalar(c1 + 65)!))
            cipher.append(Character(UnicodeScalar(c2 + 65)!))

            i += 2
        }

        return cipher
    }

    static func hillDecrypt(_ text: String, key: [[Int]]) throws -> String {
        func mod26(_ n: Int) -> Int { (n % 26 + 26) % 26 }

        let det = key[0][0] * key[1][1] - key[0][1] * key[1][0]
        let detInv = (1 ... 25).first { mod26($0 * det) == 1 } ?? 0
        guard detInv != 0 else { throw CipherError.invalidKey }

        let invKey = [
            [mod26(key[1][1] * detInv), mod26(-key[0][1] * detInv)],
            [mod26(-key[1][0] * detInv), mod26(key[0][0] * detInv)],
        ]

        let cleanText = text.uppercased().filter { $0.isLetter }
        guard cleanText.count % 2 == 0 else {
            throw CipherError.invalidKey
        }

        var plain = ""
        var i = 0
        while i < cleanText.count {
            let a = Int(cleanText[cleanText.index(cleanText.startIndex, offsetBy: i)].asciiValue! - 65)
            let b = Int(cleanText[cleanText.index(cleanText.startIndex, offsetBy: i + 1)].asciiValue! - 65)

            let p1 = mod26(invKey[0][0] * a + invKey[0][1] * b)
            let p2 = mod26(invKey[1][0] * a + invKey[1][1] * b)

            plain.append(Character(UnicodeScalar(p1 + 65)!))
            plain.append(Character(UnicodeScalar(p2 + 65)!))

            i += 2
        }

        return plain
    }

    // MARK: rail fence

    static func railFenceEncrypt(_ text: String, rails: Int) -> String {
        guard rails >= 2 else { return text }

        var fence = Array(repeating: [Character](), count: rails)
        var rail = 0
        var direction = 1

        for char in text {
            fence[rail].append(char)
            rail += direction
            if rail == 0 || rail == rails - 1 {
                direction *= -1
            }
        }

        return fence.flatMap { $0 }.map(String.init).joined()
    }

    static func railFenceDecrypt(_ text: String, rails: Int) -> String {
        guard rails >= 2 else { return text }

        let length = text.count
        var pattern = Array(repeating: 0, count: length)
        var rail = 0
        var direction = 1

        for i in 0 ..< length {
            pattern[i] = rail
            rail += direction
            if rail == 0 || rail == rails - 1 {
                direction *= -1
            }
        }

        var fence = Array(repeating: [Character](), count: rails)
        var index = text.startIndex

        for r in 0 ..< rails {
            for i in 0 ..< length where pattern[i] == r {
                fence[r].append(text[index])
                index = text.index(after: index)
            }
        }

        var result = ""
        var railIndices = Array(repeating: 0, count: rails)
        for r in pattern {
            result.append(fence[r][railIndices[r]])
            railIndices[r] += 1
        }

        return result
    }

    // MARK: euclid

    static func euclidEncrypt(_ text: String, key: Int) -> String {
        let mod = 26
        var result = ""
        for char in text.uppercased() {
            guard let ascii = char.asciiValue, char.isLetter else {
                result.append(char)
                continue
            }
            let a = Int(ascii - 65)
            let encrypted = (a * key) % mod
            result.append(Character(UnicodeScalar(encrypted + 65)!))
        }
        return result
    }

    static func euclidDecrypt(_ text: String, key: Int) -> String {
        let mod = 26
        guard let inverse = multiplicativeInverse(key, mod: mod) else { return text }

        var result = ""
        for char in text.uppercased() {
            guard let ascii = char.asciiValue, char.isLetter else {
                result.append(char)
                continue
            }
            let a = Int(ascii - 65)
            let decrypted = ((a * inverse) % mod + mod) % mod
            result.append(Character(UnicodeScalar(decrypted + 65)!))
        }
        return result
    }

    private static func multiplicativeInverse(_ a: Int, mod: Int) -> Int? {
        for i in 1 ..< mod {
            if (a * i) % mod == 1 {
                return i
            }
        }
        return nil
    }

    // MARK: AES

    static func aesEncrypt(_ text: String, key: String) -> String {
        do {
            let key16 = AES128CTRCore._deriveKey16(key)
            let iv = AES128CTRCore._makeIV16()
            let core = try AES128CTRCore(key16: key16)
            let input = Array(text.utf8)
            let cipher = try core.crypt(input, iv16: iv)
            
            return AES128CTRCore._pack(iv: iv, cipher: cipher)
        } catch {
            return text
        }
    }

    static func aesDecrypt(_ text: String, key: String) -> String {
        do {
            let (iv, cipher) = try AES128CTRCore._unpack(text, ivLen: 16)
            let key16 = AES128CTRCore._deriveKey16(key)
            let core = try AES128CTRCore(key16: key16)
            let plainBytes = try core.crypt(cipher, iv16: iv)
            
            return String(bytes: plainBytes, encoding: .utf8) ?? "[AES KEY ERROR]"
        } catch {
            return text
        }
    }

    // MARK: DES

    static func desEncrypt(_ text: String, key: String) -> String {
        do {
            let key8 = DESCore._deriveKey8(key)
            let iv8 = DESCore._makeIV8()
            let input = Array(text.utf8)
            let cipher = try DESCore.encryptCBC(input, key8: key8, iv8: iv8)
            
            return DESCore._pack(iv: iv8, cipher: cipher)
        } catch {
            return text
        }
    }

    static func desDecrypt(_ text: String, key: String) -> String {
        do {
            let (iv, cipher) = try DESCore._unpack(text, ivLen: 8)
            let key8 = DESCore._deriveKey8(key)
            let plain = try DESCore.decryptCBC(cipher, key8: key8, iv8: iv)
            
            return String(bytes: plain, encoding: .utf8) ?? "[DES KEY ERROR]"
        } catch {
            return text
        }
    }
}
