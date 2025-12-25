//
//  JoinChatViewModel.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 12.10.2025.
//

import Foundation

class JoinChatViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var recipientUsername: String = ""
    @Published var isRegistering: Bool = false
    @Published var registrationError: String?

    @MainActor
    func ensureRegistrationForRSA(username: String) async {
        guard !username.isEmpty else { return }

        isRegistering = true
        registrationError = nil

        do {
            if !Crypto.RSA.shared.hasKeys {
                print("No keys found, generating new RSA key pair...")
                try Crypto.RSA.shared.initializeNewKeys()
            }

            guard let publicKey = Crypto.RSA.shared.exportPublicKeyBase64() else {
                throw RSAError.keyExportFailed
            }

            print("Auto-registering user '\(username)' with backend...")
            do {
                try await HashchatAPI.shared.registerUser(username: username, publicKey: publicKey)
                print("User '\(username)' registered successfully")
            } catch let error as APIError {
                if case .userAlreadyExists = error {
                    print("User '\(username)' already registered, continuing...")
                } else {
                    throw error
                }
            }

        } catch let error as APIError {
            registrationError = error.localizedDescription
            print("Registration failed:", error.localizedDescription)
        } catch {
            registrationError = "Registration failed: \(error.localizedDescription)"
            print("Registration failed:", error.localizedDescription)
        }

        isRegistering = false
    }

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
    ) async -> ChatViewModel {
        let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
        let trimmedRecipient = recipientUsername.trimmingCharacters(in: .whitespaces)

        if selectedCipher == .rsa {
            await ensureRegistrationForRSA(username: trimmedUsername)
        }

        let recipientForRSA = selectedCipher == .rsa && !trimmedRecipient.isEmpty ? trimmedRecipient : nil

        let vm = ChatViewModel(
            username: trimmedUsername,
            recipientUsername: recipientForRSA,
            webSocketService: webSocketService
        )

        vm.selectedCipher = selectedCipher

        if selectedCipher == .rsa {
            vm.selectedDecryption = .none
        } else {
            vm.selectedDecryption = DecryptionType(rawValue: selectedCipher.rawValue) ?? .none
        }

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
