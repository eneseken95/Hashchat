//
//  JoinChatViewModel.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 12.10.2025.
//

import Foundation

class JoinChatViewModel: ObservableObject {
    @Published var username: String = ""

    func createChatVM(
        selectedCipher: EncryptionType,
        caesarShift: Int? = nil,
        vigenereKey: String? = nil,
        columnarKey: String? = nil,
        hillKey: [[Int]]? = nil,
        railFenceRails: Int? = nil,
        euclidKey: Int? = nil,
        aesKey: String? = nil,
        desKey: String? = nil,
        webSocketService: WebSocketService
    ) -> ChatViewModel {
        let trimmed = username.trimmingCharacters(in: .whitespaces)
        let vm = ChatViewModel(username: trimmed, webSocketService: webSocketService)

        vm.selectedCipher = selectedCipher
        vm.selectedDecryption = DecryptionType(rawValue: selectedCipher.rawValue) ?? .none

        if selectedCipher != .rsa {
            vm.caesarShift = caesarShift ?? vm.caesarShift
            vm.vigenereKey = vigenereKey ?? vm.vigenereKey
            vm.columnarKey = columnarKey ?? vm.columnarKey
            vm.hillKey = hillKey ?? vm.hillKey
            vm.railFenceRails = railFenceRails ?? vm.railFenceRails
            vm.euclidKey = euclidKey ?? vm.euclidKey
            vm.aesKey = aesKey ?? vm.aesKey
            vm.desKey = desKey ?? vm.desKey
        }

        vm.connect()
        return vm
    }
}
