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
}

class ChatViewModel: ObservableObject {
    @Published var messageText: String = ""
    @Published var messages: [Message] = []
    @Published var selectedCipher: EncryptionType = .none
    @Published var selectedDecryption: DecryptionType = .none
    @Published var recipientPublicKey: String?
    @Published var isLoadingRecipientKey: Bool = false
    @Published var errorMessage: String?

    var webSocketService: WebSocketService
    var username: String
    var recipientUsername: String?

    var caesarShift: Int = 3
    var vigenereKey: String = "hash"
    var columnarKey: String = "HASH"
    var hillKey: [[Int]] = [[3, 3], [2, 5]]
    var railFenceRails: Int = 3
    var euclidKey: Int = 7
    var aesKey: String = ""
    var desKey: String = ""

    init(username: String, recipientUsername: String? = nil, webSocketService: WebSocketService) {
        self.username = username
        self.recipientUsername = recipientUsername
        self.webSocketService = webSocketService
        bindMessages()

        if let recipient = recipientUsername {
            Task { @MainActor in
                await fetchRecipientPublicKey(for: recipient)
            }
        }
    }

    func connect() {
        webSocketService.connect(username: username)
    }

    func sendMessage() {
        guard !messageText.isEmpty else { return }

        if selectedCipher == .rsa {
            let messageData = messageText.data(using: .utf8) ?? Data()
            if messageData.count > Crypto.RSA.maxPlaintextLength {
                errorMessage = "Message too long! Max \(Crypto.RSA.maxPlaintextLength) bytes (~\(Crypto.RSA.maxPlaintextLength) chars)"
                return
            }

            if recipientPublicKey == nil {
                errorMessage = "Cannot send encrypted message: Recipient's public key not available"
                return
            }
        }

        let cipher = makeCipher(for: selectedCipher)
        let messageToSend = cipher.encrypt(messageText)

        webSocketService.send(message: messageToSend)

        let newMsg = Message(sender: username, message: messageText, timestamp: Date())
        messages.append(newMsg)

        messageText = ""
        errorMessage = nil
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
        case .rsa: return RSACipher(recipientPublicKey: recipientPublicKey)
        }
    }

    @MainActor
    func fetchRecipientPublicKey(for username: String) async {
        guard !username.isEmpty else { return }

        isLoadingRecipientKey = true
        errorMessage = nil

        do {
            print("Fetching public key for '\(username)'...")
            let publicKey = try await HashchatAPI.shared.getPublicKey(for: username)
            recipientPublicKey = publicKey
            recipientUsername = username
            print("Received public key for '\(username)'")
        } catch let error as APIError {
            errorMessage = error.localizedDescription
            print("Failed to fetch public key:", error.localizedDescription)
        } catch {
            errorMessage = "Failed to fetch public key: \(error.localizedDescription)"
            print("Failed to fetch public key:", error.localizedDescription)
        }

        isLoadingRecipientKey = false
    }
}
