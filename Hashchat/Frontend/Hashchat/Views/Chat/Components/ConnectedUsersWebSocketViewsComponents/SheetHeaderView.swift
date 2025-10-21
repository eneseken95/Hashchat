//
//  SheetHeaderView.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 21.10.2025.
//

import SwiftUI

struct SheetHeaderView: View {
    let title: String
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)

            HStack {
                Spacer()
                if let onDismiss = onDismiss {
                    Button(action: { onDismiss() }) {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(Color(red: 11 / 255, green: 185 / 255, blue: 255 / 255))
                            .fontWeight(.bold)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
    }
}
