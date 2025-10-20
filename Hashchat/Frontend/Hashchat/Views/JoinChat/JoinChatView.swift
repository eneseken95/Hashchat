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
        let trimmedUsername = joinChatViewModel.username.trimmingCharacters(in: .whitespaces)
        if trimmedUsername.isEmpty { return true }

        switch selectedEncryption {
        case .caesar:
            if caesarEncryptionShift == nil { return true }
        case .vigenere:
            if vigenereEncryptionKey?.isEmpty ?? true { return true }
        case .columnar:
            if columnarEncryptionKey?.isEmpty ?? true { return true }
        case .hill:
            for row in hillEncryptionKey {
                if row.contains(where: { $0 == nil }) { return true }
            }
        case .rota, .polybius, .pigpen, .none:
            break
        }

        switch selectedDecryption {
        case .caesar:
            if caesarDecryptionShift == nil { return true }
        case .vigenere:
            if vigenereDecryptionKey?.isEmpty ?? true { return true }
        case .columnar:
            if columnarDecryptionKey?.isEmpty ?? true { return true }
        case .hill:
            for row in hillDecryptionKey {
                if row.contains(where: { $0 == nil }) { return true }
            }
        case .rota, .polybius, .pigpen, .none:
            break
        }

        return false
    }

    private func hillEncBinding(row: Int, col: Int) -> Binding<String> {
        Binding<String>(
            get: { hillEncryptionKey[row][col].map { String($0) } ?? "" },
            set: { newValue in hillEncryptionKey[row][col] = Int(newValue) }
        )
    }

    private func hillDecBinding(row: Int, col: Int) -> Binding<String> {
        Binding<String>(
            get: { hillDecryptionKey[row][col].map { String($0) } ?? "" },
            set: { newValue in hillDecryptionKey[row][col] = Int(newValue) }
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 20) {
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

                    TextField("User name", text: $joinChatViewModel.username)
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

                        ScrollView(.horizontal, showsIndicators: false) {
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
                        }

                        if selectedEncryption == .caesar {
                            TextField("Encryption Caesar Shift", text: Binding(
                                get: { caesarEncryptionShift.map { String($0) } ?? "" },
                                set: { newValue in caesarEncryptionShift = Int(newValue) }
                            ))
                            .keyboardType(.numberPad)
                            .padding(12)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.8), lineWidth: 2))
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .padding(.horizontal, 25)
                            .padding(.top, 15)
                        }

                        if selectedEncryption == .vigenere {
                            TextField("Encryption Vigenère Key", text: Binding(
                                get: { vigenereEncryptionKey ?? "" },
                                set: { newValue in vigenereEncryptionKey = newValue.isEmpty ? nil : newValue }
                            ))
                            .padding(12)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.8), lineWidth: 2))
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .padding(.horizontal, 25)
                            .padding(.top, 15)
                        }

                        if selectedEncryption == .columnar {
                            TextField("Encryption Columnar Key", text: Binding(
                                get: { columnarEncryptionKey ?? "" },
                                set: { newValue in columnarEncryptionKey = newValue.isEmpty ? nil : newValue }
                            ))
                            .padding(12)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.8), lineWidth: 2))
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .padding(.horizontal, 25)
                            .padding(.top, 15)
                        }

                        if selectedEncryption == .hill {
                            VStack(spacing: 5) {
                                Text("Enter 2x2 Encryption Hill Cipher Key")
                                    .foregroundColor(.gray)
                                    .fontWeight(.bold)
                                    .padding(.top, 10)

                                HStack {
                                    TextField("", text: hillEncBinding(row: 0, col: 0))
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.8), lineWidth: 1))

                                    TextField("", text: hillEncBinding(row: 0, col: 1))
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.8), lineWidth: 1))
                                }

                                HStack {
                                    TextField("", text: hillEncBinding(row: 1, col: 0))
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.8), lineWidth: 1))

                                    TextField("", text: hillEncBinding(row: 1, col: 1))
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.8), lineWidth: 1))
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    VStack {
                        Text("Select Decryption Method")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color.green)

                        ScrollView(.horizontal, showsIndicators: false) {
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
                        }

                        if selectedDecryption == .caesar {
                            TextField("Decryption Caesar Shift", text: Binding(
                                get: { caesarDecryptionShift.map { String($0) } ?? "" },
                                set: { newValue in caesarDecryptionShift = Int(newValue) }
                            ))
                            .keyboardType(.numberPad)
                            .padding(12)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.8), lineWidth: 2))
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .padding(.horizontal, 25)
                            .padding(.top, 15)
                        }

                        if selectedDecryption == .vigenere {
                            TextField("Decryption Vigenère Key", text: Binding(
                                get: { vigenereDecryptionKey ?? "" },
                                set: { newValue in vigenereDecryptionKey = newValue.isEmpty ? nil : newValue }
                            ))
                            .padding(12)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.8), lineWidth: 2))
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .padding(.horizontal, 25)
                            .padding(.top, 15)
                        }

                        if selectedDecryption == .columnar {
                            TextField("Decryption Columnar Key", text: Binding(
                                get: { columnarDecryptionKey ?? "" },
                                set: { newValue in columnarDecryptionKey = newValue.isEmpty ? nil : newValue }
                            ))
                            .padding(12)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.8), lineWidth: 2))
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .padding(.horizontal, 25)
                            .padding(.top, 15)
                        }

                        if selectedDecryption == .hill {
                            VStack(spacing: 5) {
                                Text("Enter 2x2 Decryption Hill Cipher Key")
                                    .foregroundColor(.gray)
                                    .fontWeight(.bold)
                                    .padding(.top, 10)

                                HStack {
                                    TextField("", text: hillDecBinding(row: 0, col: 0))
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.8), lineWidth: 1))

                                    TextField("", text: hillDecBinding(row: 0, col: 1))
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.8), lineWidth: 1))
                                }

                                HStack {
                                    TextField("", text: hillDecBinding(row: 1, col: 0))
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.8), lineWidth: 1))

                                    TextField("", text: hillDecBinding(row: 1, col: 1))
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray.opacity(0.8), lineWidth: 1))
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    Button(action: {
                        guard !joinChatViewModel.username.trimmingCharacters(in: .whitespaces).isEmpty else { return }

                        let vm = joinChatViewModel.createChatVM(
                            selectedCipher: selectedEncryption,
                            caesarShift: caesarEncryptionShift,
                            vigenereKey: vigenereEncryptionKey,
                            columnarKey: columnarEncryptionKey,
                            hillKey: hillEncryptionKey.map { row in row.map { $0 ?? 1 } },
                            webSocketService: webSocketService
                        )

                        chatVM = vm
                        navigate = true
                    }) {
                        Text("Join Chat")
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
                        if let vm = chatVM {
                            ChatView()
                                .environmentObject(vm)
                        } else {
                            EmptyView()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    JoinChatView()
        .environmentObject(JoinChatViewModel())
}
