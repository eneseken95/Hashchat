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
        webSocketService: WebSocketService
    ) -> ChatViewModel {
        let trimmed = username.trimmingCharacters(in: .whitespaces)
        let vm = ChatViewModel(username: trimmed, webSocketService: webSocketService)

        vm.selectedCipher = selectedCipher

        if let shift = caesarShift {
            vm.caesarShift = shift
        }
        if let vKey = vigenereKey {
            vm.vigenereKey = vKey
        }
        if let cKey = columnarKey {
            vm.columnarKey = cKey
        }
        if let hKey = hillKey {
            vm.hillKey = hKey
        }
        if let rails = railFenceRails {
            vm.railFenceRails = rails
        }
        if let eKey = euclidKey {
            vm.euclidKey = eKey
        }

        vm.connect()
        return vm
    }
}
