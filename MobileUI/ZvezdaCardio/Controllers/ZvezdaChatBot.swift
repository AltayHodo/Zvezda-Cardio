//
//  ZvezdaChatBot.swift
//  ZvezdaCardio
//
//  Created by Ayush Mahale on 20/10/24.
//

import UIKit
import FirebaseVertexAI

class ZvezdaChatBot: UIViewController {
    
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var messageTextField: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    
    var messages: [String] = []

    override func viewDidLoad() {
            super.viewDidLoad()
            chatTextView.text = "Welcome to the Zvezda AI Chatbot!\n"
        chatTextView.isScrollEnabled = true
        sendButton.tintColor = .orange
        }

        @IBAction func sendMessage(_ sender: UIButton) {
            let userMessage = messageTextField.text ?? ""
            if !userMessage.isEmpty {
                startChat(with: userMessage)
                messageTextField.text = ""
            }
        }

        func startChat(with userMessage: String) {
            let prompt = userMessage

            let vertex = VertexAI.vertexAI()
            let model = vertex.generativeModel(modelName: "gemini-1.5-flash")
            
            Task {
                do {
                    let response = try await model.generateContent(prompt)
                    if let text = response.text {
                        displayMessage(text, fromUser: false)  // Display AI's response
                    }
                } catch {
                    print("Error generating content: \(error)")
                }
            }
            
            displayMessage(userMessage, fromUser: true)
        }
        
        func displayMessage(_ message: String, fromUser: Bool) {
            let formattedMessage = fromUser ? "You: \(message)\n" : "AI: \(message)\n"
            chatTextView.text += formattedMessage
        }
    }
