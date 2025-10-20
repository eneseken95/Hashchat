//
//  BubbleShape.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 18.10.2025.
//

import SwiftUI

struct BubbleShape: Shape {
    let isCurrentUser: Bool

    func path(in rect: CGRect) -> Path {
        let cornerRadius: CGFloat = 16
        let tailSize: CGFloat = 10
        var path = Path()

        let tailVerticalRadius: CGFloat = 5
        let downwardOffset: CGFloat = 3

        if isCurrentUser {
            path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.width - tailSize - cornerRadius, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.width - tailSize - cornerRadius, y: rect.minY + cornerRadius), radius: cornerRadius, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
            path.addLine(to: CGPoint(x: rect.width - tailSize, y: rect.maxY - cornerRadius))
            path.addArc(center: CGPoint(x: rect.width - tailSize - cornerRadius, y: rect.maxY - cornerRadius), radius: cornerRadius, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
            path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius), radius: cornerRadius, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
            path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.minY + cornerRadius), radius: cornerRadius, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)

            var tail = Path()
            let tailY = rect.maxY - cornerRadius - tailVerticalRadius + downwardOffset

            tail.move(to: CGPoint(x: rect.width - tailSize, y: tailY - tailVerticalRadius))
            tail.addLine(to: CGPoint(x: rect.width, y: tailY))
            tail.addLine(to: CGPoint(x: rect.width - tailSize, y: tailY + tailVerticalRadius))
            tail.closeSubpath()
            path.addPath(tail)
        } else {
            path.move(to: CGPoint(x: rect.width - cornerRadius, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX + tailSize + cornerRadius, y: rect.minY))
            path.addArc(center: CGPoint(x: rect.minX + tailSize + cornerRadius, y: rect.minY + cornerRadius), radius: cornerRadius, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: -180), clockwise: true)
            path.addLine(to: CGPoint(x: rect.minX + tailSize, y: rect.maxY - cornerRadius))
            path.addArc(center: CGPoint(x: rect.minX + tailSize + cornerRadius, y: rect.maxY - cornerRadius), radius: cornerRadius, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 90), clockwise: true)
            path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: rect.maxY))
            path.addArc(center: CGPoint(x: rect.width - cornerRadius, y: rect.maxY - cornerRadius), radius: cornerRadius, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 0), clockwise: true)
            path.addLine(to: CGPoint(x: rect.width, y: rect.minY + cornerRadius))
            path.addArc(center: CGPoint(x: rect.width - cornerRadius, y: rect.minY + cornerRadius), radius: cornerRadius, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: -90), clockwise: true)

            var tail = Path()
            let tailY = rect.maxY - cornerRadius - tailVerticalRadius + downwardOffset

            tail.move(to: CGPoint(x: rect.minX + tailSize, y: tailY - tailVerticalRadius))
            tail.addLine(to: CGPoint(x: rect.minX, y: tailY))
            tail.addLine(to: CGPoint(x: rect.minX + tailSize, y: tailY + tailVerticalRadius))
            tail.closeSubpath()
            path.addPath(tail)
        }

        return path
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VStack(spacing: 30) {
        BubbleShape(isCurrentUser: true)
            .fill(Color.blue)
            .frame(width: 200, height: 60)
            .overlay(
                Text("Hello!")
                    .foregroundColor(.white)
                    .bold()
            )

        BubbleShape(isCurrentUser: false)
            .fill(Color.gray.opacity(0.3))
            .frame(width: 200, height: 60)
            .overlay(
                Text("Hi there!")
                    .foregroundColor(.black)
                    .bold()
            )
    }
    .padding()
    .background(Color(red: 238 / 255, green: 239 / 255, blue: 238 / 255))
}
