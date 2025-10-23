//
//  CipherSelectionView.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 21.10.2025.
//

import SwiftUI

struct CipherSelectionView<T: CaseIterable & RawRepresentable & Hashable>: View where T.RawValue == String {
    let title: String
    let types: [T]

    @Binding var selected: T
    @Binding var shift: Int?
    @Binding var key: String?
    @Binding var columnar: String?
    @Binding var railFenceRails: Int?
    @Binding var euclidKey: Int?
    let hill: [[Int?]]
    let encryption: Bool
    let animationNamespace: Namespace.ID
    let hillBinding: (Int, Int) -> Binding<String>

    var body: some View {
        VStack(spacing: 10) {
            Text("Select \(title) Method")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(title == "Encryption" ? .pink : .green)

            cipherPicker
            cipherInput
        }
    }

    private var cipherPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(types, id: \.self) { type in
                    let isSelected = selected == type
                    let bgColor: Color = (title == "Encryption" ? .pink : .green)

                    Text(type.rawValue)
                        .foregroundColor(isSelected ? .white : .gray)
                        .fontWeight(.bold)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(minWidth: 105)
                        .background(
                            Group {
                                if isSelected {
                                    bgColor.opacity(0.8)
                                        .matchedGeometryEffect(id: title, in: animationNamespace)
                                }
                            }
                        )
                        .cornerRadius(12)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selected = type
                            }
                        }
                }
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private var cipherInput: some View {
        switch selected.rawValue.lowercased() {
        case "caesar":
            JoinChatView.cipherTextField("Caesar Shift", intBinding: $shift)
        case "vigenere":
            JoinChatView.cipherTextField("Vigenère Key", stringBinding: $key)
        case "columnar":
            JoinChatView.cipherTextField("Columnar Key", stringBinding: $columnar)
        case "hill":
            JoinChatView.hillCipherView(hillBinding: hillBinding, encryption: encryption)
        case "euclid":
            JoinChatView.cipherTextField("Euclid Key", intBinding: $euclidKey)
        case "rail fence":
            JoinChatView.cipherTextField("Number of Rails", intBinding: $railFenceRails)
        default:
            EmptyView()
        }
    }
}
