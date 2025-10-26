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
    @State var selectedEncryption: EncryptionType = .none
    @State var selectedDecryption: DecryptionType = .none

    @State var caesarEncryptionShift: Int? = nil
    @State var caesarDecryptionShift: Int? = nil
    @State var vigenereEncryptionKey: String? = nil
    @State var vigenereDecryptionKey: String? = nil
    @State var columnarEncryptionKey: String? = nil
    @State var columnarDecryptionKey: String? = nil
    @State var hillEncryptionKey: [[Int?]] = [[nil, nil], [nil, nil]]
    @State var hillDecryptionKey: [[Int?]] = [[nil, nil], [nil, nil]]
    @State var railFenceEncryptionRails: Int? = nil
    @State var railFenceDecryptionRails: Int? = nil
    @State var euclidEncryptionKey: Int? = nil
    @State var euclidDecryptionKey: Int? = nil

    @Namespace private var animationNamespace

    private var isLoginDisabled: Bool {
        !isCipherInputValid()
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                ScrollView {
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
                            railFenceRails: $railFenceEncryptionRails,
                            euclidKey: $euclidEncryptionKey,
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
                            railFenceRails: $railFenceDecryptionRails,
                            euclidKey: $euclidDecryptionKey,
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
                                railFenceRails: railFenceEncryptionRails,
                                euclidKey: euclidEncryptionKey,
                                webSocketService: webSocketService
                            )
                            chatVM = vm
                            navigate = true
                        }
                    }
                    .padding(.top, 80)
                    .navigationDestination(isPresented: $navigate) {
                        if let vm = chatVM {
                            ChatView().environmentObject(vm)
                        } else {
                            EmptyView()
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .onTapGesture {
                    hideKeyboard()
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
