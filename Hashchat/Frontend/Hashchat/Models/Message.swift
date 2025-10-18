//
//  Message.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 12.10.2025.
//

import Foundation

struct Message: Codable, Identifiable, Equatable {
    var id = UUID()
    var sender: String
    var message: String

    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
}
