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
        caesarEncShift: Int?,
        caesarDecShift: Int?,
        vigenereEncKey: String?,
        vigenereDecKey: String?
    ) -> ChatViewModel {
        let trimmed = username.trimmingCharacters(in: .whitespaces)
        let vm = ChatViewModel(username: trimmed)

        vm.selectedEncryption = encryption
        vm.selectedDecryption = decryption
        vm.caesarEncryptionShift = caesarEncShift ?? 3
        vm.vigenereEncryptionKey = vigenereEncKey ?? "hash"
        vm.caesarDecryptionShift = caesarDecShift ?? 3
        vm.vigenereDecryptionKey = vigenereDecKey ?? "hash"

        vm.connect()
        return vm
    }
}
