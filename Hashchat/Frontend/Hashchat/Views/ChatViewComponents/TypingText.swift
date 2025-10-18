//
//  TypingText.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 18.10.2025.
//

import SwiftUI

struct TypingText: View {
    let fullText: String
    let isActive: Bool
    @State private var displayedText: String = ""
    let interval: TimeInterval

    init(_ text: String, isActive: Bool = true, interval: TimeInterval = 0.05) {
        fullText = text
        self.isActive = isActive
        self.interval = interval
    }

    var body: some View {
        Text(displayedText)
            .font(.title2)
            .fontWeight(.bold)
            .foregroundStyle(Color.black.opacity(0.8))
            .onAppear {
                if isActive {
                    animateText()
                } else {
                    displayedText = fullText
                }
            }
            .onChange(of: isActive) {
                if isActive {
                    animateText()
                } else {
                    displayedText = fullText
                }
            }
    }

    private func animateText() {
        guard isActive else { return }
        displayedText = ""
        var currentIndex = 0
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if !isActive {
                displayedText = fullText
                timer.invalidate()
                return
            }

            if currentIndex < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
                displayedText.append(fullText[index])
                currentIndex += 1
            } else {
                timer.invalidate()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    animateText()
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        TypingText("Searching for user...", isActive: true)
            .padding()
            .background(Color.orange.opacity(0.2))
            .cornerRadius(12)

        TypingText("Connection established!", isActive: false)
            .padding()
            .background(Color.green.opacity(0.2))
            .cornerRadius(12)
    }
    .padding()
    .background(Color.white)
}
