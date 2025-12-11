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
    case railfence = "Rail Fence"
    case euclid = "Euclid"
    case aes = "AES"
    case des = "DES"
    case rsa = "RSA"
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
    case railfence = "Rail Fence"
    case euclid = "Euclid"
    case aes = "AES"
    case des = "DES"
    case rsa = "RSA"
}

class ChatViewModel: ObservableObject {
    @Published var messageText: String = ""
    @Published var messages: [Message] = []
    @Published var selectedCipher: EncryptionType = .none
    @Published var selectedDecryption: DecryptionType = .none

    var webSocketService: WebSocketService
    var username: String

    var caesarShift: Int = 3
    var vigenereKey: String = "hash"
    var columnarKey: String = "HASH"
    var hillKey: [[Int]] = [[3, 3], [2, 5]]
    var railFenceRails: Int = 3
    var euclidKey: Int = 7
    var aesKey: String = ""
    var desKey: String = ""

    init(username: String, webSocketService: WebSocketService) {
        self.username = username
        self.webSocketService = webSocketService
        bindMessages()
    }

    func connect() {
        webSocketService.connect(username: username)
    }

    func sendMessage() {
        guard !messageText.isEmpty else { return }

        let cipher = makeCipher(for: selectedCipher)
        let messageToSend = cipher.encrypt(messageText)

        webSocketService.send(message: messageToSend)

        let newMsg = Message(sender: username, message: messageText, timestamp: Date())
        messages.append(newMsg)

        messageText = ""
    }

    private func decryptMessage(_ text: String) -> String {
        let cipher = makeCipher(for: selectedCipher)
        return cipher.decrypt(text)
    }

    private func bindMessages() {
        webSocketService.newMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] msg in
                guard let self = self else { return }

                if msg.sender != self.username {
                    let decrypted = self.decryptMessage(msg.message)
                    let finalMsg = Message(sender: msg.sender, message: decrypted, timestamp: Date())
                    self.messages.append(finalMsg)
                }
            }
            .store(in: &webSocketService.cancellables)
    }

    private func makeCipher(for type: EncryptionType) -> CipherProtocol {
        switch type {
        case .none: return PlainCipher()
        case .caesar: return CaesarCipher(shift: caesarShift)
        case .vigenere: return VigenereCipher(key: vigenereKey)
        case .rota: return RotaCipher()
        case .columnar: return ColumnarCipher(key: columnarKey)
        case .polybius: return PolybiusCipher()
        case .pigpen: return PigpenCipher()
        case .hill: return HillCipher(key: hillKey)
        case .railfence: return RailFenceCipher(rails: railFenceRails)
        case .euclid: return EuclidCipher(key: euclidKey)
        case .aes: return AESCipher(key: aesKey)
        case .des: return DESCipher(key: desKey)
        case .rsa: return RSACipher()
        }
    }
}
