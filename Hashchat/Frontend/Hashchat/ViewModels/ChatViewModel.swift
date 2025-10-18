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
    case rota = "Rota"
    case columnar = "Columnar"
    case polybius = "Polybius"
    case pigpen = "Pigpen"
    case hill = "Hill"
}

enum DecryptionType: String, CaseIterable {
    case none = "None"
    case caesar = "Caesar"
    case vigenere = "Vigenere"
    case rota = "Rota"
    case columnar = "Columnar"
    case polybius = "Polybius"
    case pigpen = "Pigpen"
    case hill = "Hill"
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

    var columnarEncryptionKey: String = "HASH"
    var columnarDecryptionKey: String = "HASH"

    var polybiusEncryption: Bool = false
    var polybiusDecryption: Bool = false

    var pigpenEncryption: Bool = false
    var pigpenDecryption: Bool = false

    var hillEncryptionKey: [[Int]] = [[3, 3], [2, 5]]
    var hillDecryptionKey: [[Int]] = [[3, 3], [2, 5]]

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
        case .rota:
            messageToSend = Crypto.rotaEncrypt(messageText)
        case .columnar:
            messageToSend = Crypto.columnarEncrypt(messageText, key: columnarEncryptionKey)
        case .polybius:
            messageToSend = Crypto.polybiusEncrypt(messageText)
        case .pigpen:
            messageToSend = Crypto.pigpenEncrypt(messageText)
        case .hill:
            do {
                messageToSend = try Crypto.hillEncrypt(messageText, key: hillEncryptionKey)
            } catch {
                messageToSend = messageText
            }

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
                    case .rota:
                        decrypted = Crypto.rotaDecrypt(msg.message)
                    case .columnar:
                        decrypted = Crypto.columnarDecrypt(msg.message, key: columnarDecryptionKey)
                    case .polybius:
                        decrypted = Crypto.polybiusDecrypt(msg.message)
                    case .pigpen:
                        decrypted = Crypto.pigpenDecrypt(msg.message)
                    case .hill:
                        do {
                            decrypted = try Crypto.hillDecrypt(msg.message, key: hillDecryptionKey)
                        } catch {
                            decrypted = msg.message
                        }
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
