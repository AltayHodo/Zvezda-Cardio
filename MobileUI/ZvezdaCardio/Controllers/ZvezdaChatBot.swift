//
//  ZvezdaChatBot.swift
//  ZvezdaCardio
//
//  Created by Ayush Mahale on 20/10/24.
//

import UIKit
import FirebaseVertexAI

class ZvezdaChatBot: UIView {
    func startChat() {
        let chat = VertexAIChat(
            apiKey: "YOUR_API_KEY",
            language: .english,
            sessionID: "YOUR_SESSION_ID"
        )
        chat.startChat()
    }
}
