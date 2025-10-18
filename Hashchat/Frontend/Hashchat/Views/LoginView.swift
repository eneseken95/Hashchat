//
//  LoginView.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 12.10.2025.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var navigate = false
    @State private var chatVM: ChatViewModel? = nil
    @State private var selectedEncryption: EncryptionType = .none
    @State private var selectedDecryption: DecryptionType = .none

    @State private var caesarEncryptionShift: Int? = nil
    @State private var caesarDecryptionShift: Int? = nil
    @State private var vigenereEncryptionKey: String? = nil
    @State private var vigenereDecryptionKey: String? = nil

    @Namespace private var animationNamespace
    private var isLoginDisabled: Bool {
        let trimmedUsername = viewModel.username.trimmingCharacters(in: .whitespaces)

        if trimmedUsername.isEmpty { return true }

        switch selectedEncryption {
        case .caesar:
            if caesarEncryptionShift == nil { return true }
        case .vigenere:
            if vigenereEncryptionKey?.isEmpty ?? true { return true }
        case .none:
            break
        }

        switch selectedDecryption {
        case .caesar:
            if caesarDecryptionShift == nil { return true }
        case .vigenere:
            if vigenereDecryptionKey?.isEmpty ?? true { return true }
        case .none:
            break
        }

        return false
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 30) {
                    VStack(spacing: 10) {
                        Image("Hashchat")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 3)

                        Text("HashChat")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.cyan.opacity(0.8), Color.blue],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }

                    TextField("User name", text: $viewModel.username)
                        .padding(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.8), lineWidth: 2)
                        )
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                        .padding(.horizontal, 25)
                        .padding(.bottom, 5)

                    VStack {
                        Text("Select Encryption Method")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color.pink)

                        HStack(spacing: 8) {
                            ForEach(EncryptionType.allCases, id: \.self) { type in
                                Text(type.rawValue)
                                    .foregroundColor(selectedEncryption == type ? .white : .gray)
                                    .fontWeight(.bold)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .frame(minWidth: 105)
                                    .background(
                                        ZStack {
                                            if selectedEncryption == type {
                                                Color.pink.opacity(0.8)
                                                    .matchedGeometryEffect(id: "encryption", in: animationNamespace)
                                            }
                                        }
                                    )
                                    .cornerRadius(12)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedEncryption = type
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)

                        if selectedEncryption == .caesar {
                            HStack {
                                TextField("Encryption Caesar Shift", text: Binding(
                                    get: { caesarEncryptionShift.map { String($0) } ?? "" },
                                    set: { newValue in
                                        caesarEncryptionShift = Int(newValue)
                                    }
                                ))
                                .keyboardType(.numberPad)
                                .padding(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray.opacity(0.8), lineWidth: 2)
                                )
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                            }
                            .padding(.horizontal, 25)
                            .padding(.top, 15)
                        }

                        if selectedEncryption == .vigenere {
                            HStack {
                                TextField("Encryption Vigenère Key", text: Binding(
                                    get: { vigenereEncryptionKey ?? "" },
                                    set: { newValue in
                                        vigenereEncryptionKey = newValue.isEmpty ? nil : newValue
                                    }
                                ))
                                .padding(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray.opacity(0.8), lineWidth: 2)
                                )
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                            }
                            .padding(.horizontal, 25)
                            .padding(.top, 15)
                        }
                    }

                    VStack {
                        Text("Select Decryption Method")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color.green)

                        HStack(spacing: 8) {
                            ForEach(DecryptionType.allCases, id: \.self) { type in
                                Text(type.rawValue)
                                    .foregroundColor(selectedDecryption == type ? .white : .gray)
                                    .fontWeight(.bold)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .frame(minWidth: 105)
                                    .background(
                                        ZStack {
                                            if selectedDecryption == type {
                                                Color.green.opacity(0.8)
                                                    .matchedGeometryEffect(id: "decryption", in: animationNamespace)
                                            }
                                        }
                                    )
                                    .cornerRadius(12)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedDecryption = type
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal)

                        if selectedDecryption == .caesar {
                            HStack {
                                TextField("Decryption Caesar Shift", text: Binding(
                                    get: { caesarDecryptionShift.map { String($0) } ?? "" },
                                    set: { newValue in
                                        caesarDecryptionShift = Int(newValue)
                                    }
                                ))
                                .keyboardType(.numberPad)
                                .padding(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray.opacity(0.8), lineWidth: 2)
                                )
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                            }
                            .padding(.horizontal, 25)
                            .padding(.top, 15)
                        }

                        if selectedDecryption == .vigenere {
                            HStack {
                                TextField("Decryption Vigenère Key", text: Binding(
                                    get: { vigenereDecryptionKey ?? "" },
                                    set: { newValue in
                                        vigenereDecryptionKey = newValue.isEmpty ? nil : newValue
                                    }
                                ))
                                .padding(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray.opacity(0.8), lineWidth: 2)
                                )
                                .foregroundColor(.black)
                                .fontWeight(.bold)
                            }
                            .padding(.horizontal, 25)
                            .padding(.top, 15)
                        }
                    }

                    Button(action: {
                        guard !viewModel.username.trimmingCharacters(in: .whitespaces).isEmpty else { return }

                        let vm = viewModel.createChatVM(
                            encryption: selectedEncryption,
                            decryption: selectedDecryption,
                            caesarEncShift: caesarEncryptionShift,
                            caesarDecShift: caesarDecryptionShift,
                            vigenereEncKey: vigenereEncryptionKey,
                            vigenereDecKey: vigenereDecryptionKey
                        )

                        chatVM = vm
                        navigate = true
                    }) {
                        Text("Login")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.cyan.opacity(0.8), Color.blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(25)
                            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 3)
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 10)
                    .disabled(isLoginDisabled)
                    .opacity(isLoginDisabled ? 0.5 : 1.0)
                    .navigationDestination(isPresented: $navigate) {
                        if let chatVM {
                            ChatView(viewModel: chatVM)
                        } else {
                            EmptyView()
                        }
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    LoginView()
}
