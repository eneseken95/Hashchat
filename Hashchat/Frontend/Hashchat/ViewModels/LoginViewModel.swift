//
//  LoginViewModel.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 12.10.2025.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var username: String = ""

    func createChatVM(
        encryption: EncryptionType,
        decryption: DecryptionType,
        caesarEncShift: Int? = nil,
        caesarDecShift: Int? = nil,
        vigenereEncKey: String? = nil,
        vigenereDecKey: String? = nil,
        columnarEncKey: String? = nil,
        columnarDecKey: String? = nil,
        hillEncKey: [[Int]]? = nil,
        hillDecKey: [[Int]]? = nil
    ) -> ChatViewModel {
        let trimmed = username.trimmingCharacters(in: .whitespaces)
        let vm = ChatViewModel(username: trimmed)

        vm.selectedEncryption = encryption
        vm.selectedDecryption = decryption

        vm.caesarEncryptionShift = caesarEncShift ?? 3
        vm.caesarDecryptionShift = caesarDecShift ?? 3

        vm.vigenereEncryptionKey = vigenereEncKey ?? "hash"
        vm.vigenereDecryptionKey = vigenereDecKey ?? "hash"

        vm.columnarEncryptionKey = columnarEncKey ?? "HASH"
        vm.columnarDecryptionKey = columnarDecKey ?? "HASH"

        vm.hillEncryptionKey = hillEncKey ?? [[3, 3], [2, 5]]
        vm.hillDecryptionKey = hillDecKey ?? [[3, 3], [2, 5]]

        vm.connect()
        return vm
    }
}
