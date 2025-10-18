//
//  Crypto.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 12.10.2025.
//

import Foundation

final class Crypto {
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
}
