//
//  ChatViewModel.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 12.10.2025.
//

import Combine
import Foundation

enum EncryptionType: String, CaseIterable {
    case none = "None"
    case caesar = "Caesar"
    case vigenere = "Vigenere"
}

enum DecryptionType: String, CaseIterable {
    case none = "None"
    case caesar = "Caesar"
    case vigenere = "Vigenere"
}

class ChatViewModel: ObservableObject {
    @Published var messageText: String = ""
    @Published var messages: [Message] = []
    @Published var selectedEncryption: EncryptionType = .none
    @Published var selectedDecryption: DecryptionType = .none

    var webSocketService = WebSocketService()
    var username: String
    var caesarEncryptionShift: Int = 3
    var caesarDecryptionShift: Int = 3
    var vigenereEncryptionKey: String = "hash"
    var vigenereDecryptionKey: String = "hash"

    init(username: String) {
        self.username = username
        bindMessages()
    }

    func connect() {
        webSocketService.connect(username: username)
    }

    func sendMessage() {
        guard !messageText.isEmpty else { return }

        var messageToSend = messageText

        switch selectedEncryption {
        case .caesar:
            messageToSend = Crypto.caesarEncrypt(messageText, shift: caesarEncryptionShift)
        case .vigenere:
            messageToSend = Crypto.vigenereEncrypt(messageText, key: vigenereEncryptionKey)
        case .none:
            break
        }

        webSocketService.send(message: messageToSend)

        let newMsg = Message(sender: username, message: messageText)
        messages.append(newMsg)

        messageText = ""
    }

    private func bindMessages() {
        webSocketService.newMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] msg in
                guard let self = self else { return }

                if msg.sender != self.username {
                    var decrypted = msg.message

                    switch self.selectedDecryption {
                    case .caesar:
                        decrypted = Crypto.caesarDecrypt(msg.message, shift: self.caesarDecryptionShift)
                    case .vigenere:
                        decrypted = Crypto.vigenereDecrypt(msg.message, key: self.vigenereDecryptionKey)
                    case .none:
                        break
                    }

                    let finalMsg = Message(sender: msg.sender, message: decrypted)
                    self.messages.append(finalMsg)
                }
            }
            .store(in: &webSocketService.cancellables)
    }
}
