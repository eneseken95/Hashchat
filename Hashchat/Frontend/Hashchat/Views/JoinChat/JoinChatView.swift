//
//  JoinChatView.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 12.10.2025.
//

import SwiftUI

struct JoinChatView: View {
    @EnvironmentObject var joinChatViewModel: JoinChatViewModel
    @EnvironmentObject var webSocketService: WebSocketService

    @State private var navigate = false
    @State private var chatVM: ChatViewModel? = nil
    @State private var selectedEncryption: EncryptionType = .none
    @State private var selectedDecryption: DecryptionType = .none

    @State private var caesarEncryptionShift: Int? = nil
    @State private var caesarDecryptionShift: Int? = nil
    @State private var vigenereEncryptionKey: String? = nil
    @State private var vigenereDecryptionKey: String? = nil
    @State private var columnarEncryptionKey: String? = nil
    @State private var columnarDecryptionKey: String? = nil
    @State private var hillEncryptionKey: [[Int?]] = [[nil, nil], [nil, nil]]
    @State private var hillDecryptionKey: [[Int?]] = [[nil, nil], [nil, nil]]

    @Namespace private var animationNamespace

    private var isLoginDisabled: Bool {
        let trimmed = joinChatViewModel.username.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return true }

        switch selectedEncryption {
        case .caesar: if caesarEncryptionShift == nil { return true }
        case .vigenere: if vigenereEncryptionKey?.isEmpty ?? true { return true }
        case .columnar: if columnarEncryptionKey?.isEmpty ?? true { return true }
        case .hill: if hillEncryptionKey.flatMap({ $0 }).contains(nil) { return true }
        default: break
        }

        switch selectedDecryption {
        case .caesar: if caesarDecryptionShift == nil { return true }
        case .vigenere: if vigenereDecryptionKey?.isEmpty ?? true { return true }
        case .columnar: if columnarDecryptionKey?.isEmpty ?? true { return true }
        case .hill: if hillDecryptionKey.flatMap({ $0 }).contains(nil) { return true }
        default: break
        }

        return false
    }

    private func hillEncBinding(row: Int, col: Int) -> Binding<String> {
        Binding<String>(
            get: { hillEncryptionKey[row][col].map { String($0) } ?? "" },
            set: { hillEncryptionKey[row][col] = Int($0) }
        )
    }

    private func hillDecBinding(row: Int, col: Int) -> Binding<String> {
        Binding<String>(
            get: { hillDecryptionKey[row][col].map { String($0) } ?? "" },
            set: { hillDecryptionKey[row][col] = Int($0) }
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 20) {
                    HeaderView()

                    UsernameFieldView(username: $joinChatViewModel.username)

                    CipherSelectionView(
                        title: "Encryption",
                        types: EncryptionType.allCases,
                        selected: $selectedEncryption,
                        shift: $caesarEncryptionShift,
                        key: $vigenereEncryptionKey,
                        columnar: $columnarEncryptionKey,
                        hill: hillEncryptionKey,
                        encryption: true,
                        animationNamespace: animationNamespace,
                        hillBinding: hillEncBinding
                    )

                    CipherSelectionView(
                        title: "Decryption",
                        types: DecryptionType.allCases,
                        selected: $selectedDecryption,
                        shift: $caesarDecryptionShift,
                        key: $vigenereDecryptionKey,
                        columnar: $columnarDecryptionKey,
                        hill: hillDecryptionKey,
                        encryption: false,
                        animationNamespace: animationNamespace,
                        hillBinding: hillDecBinding
                    )

                    JoinButtonView(
                        username: joinChatViewModel.username,
                        isEnabled: !isLoginDisabled
                    ) {
                        let vm = joinChatViewModel.createChatVM(
                            selectedCipher: selectedEncryption,
                            caesarShift: caesarEncryptionShift,
                            vigenereKey: vigenereEncryptionKey,
                            columnarKey: columnarEncryptionKey,
                            hillKey: hillEncryptionKey.map { $0.map { $0 ?? 1 } },
                            webSocketService: webSocketService
                        )
                        chatVM = vm
                        navigate = true
                    }
                }
                .navigationDestination(isPresented: $navigate) {
                    if let vm = chatVM {
                        ChatView().environmentObject(vm)
                    } else {
                        EmptyView()
                    }
                }
            }
        }
    }
}

#Preview {
    JoinChatView()
        .environmentObject(JoinChatViewModel())
        .environmentObject(WebSocketService())
}
