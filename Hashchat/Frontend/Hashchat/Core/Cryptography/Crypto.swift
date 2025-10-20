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
}
