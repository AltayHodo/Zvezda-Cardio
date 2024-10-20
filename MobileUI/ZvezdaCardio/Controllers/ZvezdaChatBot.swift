//
//  ZvezdaChatBot.swift
//  ZvezdaCardio
//
//  Created by Ayush Mahale on 20/10/24.
//

import UIKit
import FirebaseVertexAI
import FirebaseCore
import FirebaseFirestore

class ZvezdaChatBot: UIViewController {
    
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var messageTextField: UITextView!
    @IBOutlet weak var sendButton: UIButton!

    var messages: [String] = []
    var email: String?
    var steps: Int?

    override func viewDidLoad() {
            super.viewDidLoad()
            chatTextView.text = "Welcome to the Zvezda AI Chatbot!\n"
        chatTextView.isScrollEnabled = true
        sendButton.tintColor = .orange
        }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func sendMessage(_ sender: UIButton) {
        let userMessage = messageTextField.text ?? ""
        if !userMessage.isEmpty {
            processUserMessage(userMessage)
            messageTextField.text = ""
            }
        }
    
    func checkAndUpdateDailySteps(completion: @escaping (Int) -> Void) {
        let db = Firestore.firestore()
        guard let userEmail = email else { return }

        let userRef = db.collection("User").document(userEmail)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let userDocument: DocumentSnapshot
            do {
                userDocument = try transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                print("Error fetching document: \(fetchError)")
                return nil
            }

            guard let data = userDocument.data() else {
                return nil
            }
            
            let totalSteps = data["totalSteps"] as? Int ?? 0
            let lastKnownSteps = data["lastKnownSteps"] as? Int ?? totalSteps
            let lastKnownStepsDate = (data["lastKnownStepsDate"] as? Timestamp)?.dateValue() ?? Date.distantPast
            
            let calendar = Calendar.current
            let currentDate = calendar.startOfDay(for: Date())
            let lastDate = calendar.startOfDay(for: lastKnownStepsDate)

            if currentDate > lastDate {
                // A new day has started, reset lastKnownSteps to current totalSteps
                transaction.updateData([
                    "lastKnownSteps": totalSteps,
                    "lastKnownStepsDate": Timestamp(date: currentDate)
                ], forDocument: userRef)
                completion(totalSteps)
            } else {
                // It's still the same day, return the existing lastKnownSteps
                completion(lastKnownSteps)
            }

            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
                completion(0)
            } else {
                print("Transaction successful")
            }
        }
    }
    func generateDailyFeedbackForUser() {
        checkAndUpdateDailySteps { lastKnownSteps in
            
            let db = Firestore.firestore()
            guard let userEmail = self.email else { return }

            db.collection("User").document(userEmail).getDocument { (document, error) in
                if let document = document, document.exists {
                    let data = document.data()
                    let totalSteps = data?["totalSteps"] as? Int ?? 0
                    let stepsToday =  totalSteps // Steps taken today
                    
                    let stepGoal = data?["stepGoal"] as? Int ?? 9163  // Default daily goal of 9,163 steps
                    let feedback = self.generateFeedback(stepGoal: stepGoal, stepsToday: stepsToday)
                    
                    // Display feedback in the chat UI
                    self.displayMessage(feedback, fromUser: false)
                } else {
                    // If document does not exist, display an error message and stop the loader
                    self.displayMessage("Could not retrieve step data. Please try again later.", fromUser: false)
                }
            }
        }
    }
    func generateFeedback(stepGoal: Int, stepsToday: Int) -> String {
            if stepsToday >= stepGoal {
                return "Great job! You've reached your step goal for today. Keep it up!"
            } else {
                let stepsRemaining = stepGoal - stepsToday
                return "You're \(stepsRemaining) steps away from your goal. Keep pushing, you can do it!"
            }
        }

    func processUserMessage(_ userMessage: String) {
        if userMessage.lowercased().contains("step progress") || userMessage.lowercased().contains("steps today") || userMessage.lowercased().contains("steps") {
            generateDailyFeedbackForUser()
        } else {
            startChat(with: userMessage)
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
