//
//  KeychainManager.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 25.12.2025.
//

import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()

    private let service = "com.hashchat.rsa"
    private let privateKeyAccount = "rsa_private_key"

    private init() {}

    func savePrivateKey(_ keyData: Data) throws {
        try? deletePrivateKey()

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: privateKeyAccount,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status: status)
        }
    }

    func loadPrivateKey() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: privateKeyAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let keyData = result as? Data else {
            return nil
        }

        return keyData
    }

    func deletePrivateKey() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: privateKeyAccount,
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status: status)
        }
    }

    func privateKeyExists() -> Bool {
        return loadPrivateKey() != nil
    }
}

enum KeychainError: Error {
    case saveFailed(status: OSStatus)
    case deleteFailed(status: OSStatus)

    var localizedDescription: String {
        switch self {
        case let .saveFailed(status):
            return "Failed to save key to Keychain: \(status)"
        case let .deleteFailed(status):
            return "Failed to delete key from Keychain: \(status)"
        }
    }
}
