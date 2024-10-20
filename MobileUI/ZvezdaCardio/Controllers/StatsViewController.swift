//
//  StatsViewController.swift
//  ZvezdaCardio
//
//  Created by Ayush Mahale on 19/10/24.
//

import UIKit
import MapKit
import HealthKit
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore

class StatsViewController: UIViewController, CLLocationManagerDelegate {
    
    let healthStore = HKHealthStore()
    
    @IBOutlet weak var calories: UILabel!
    @IBOutlet weak var steps: UILabel!
    @IBOutlet weak var points: UILabel!
    
    @IBOutlet weak var lifetimeCalories: UILabel!
    @IBOutlet weak var lifetimeSteps: UILabel!
    @IBOutlet weak var lifetimePoints: UILabel!
    
    var email: String?
    
    var stepAnchor: HKQueryAnchor?
    var energyAnchor: HKQueryAnchor?
    var totalPoints = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestHealthKitAuthorization()
    }
    override func viewDidAppear(_ animated: Bool) {
        loadLifetimeStats()
    }
    
    
    func loadLifetimeStats() {
        let db = Firestore.firestore()
        db.collection("User").document(self.email!).getDocument { (document, error) in
            if error == nil {
                if document != nil && document!.exists {
                    let documentData = document!.data()
                    self.lifetimeCalories.text = "\(documentData!["totalCalories"] ?? 0) kcal"
                    self.lifetimeSteps.text = "\(documentData!["totalSteps"] ?? 0) steps"
                    self.lifetimePoints.text = "\(documentData!["totalPoints"] ?? 0) points"
                }
            }
        }
    }
    
    func requestHealthKitAuthorization() {
            let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            let activeEnergyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!

            let typesToRead: Set = [stepCountType, activeEnergyType]

            healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
                if success {
                    self.loadPreviousStepsFromFirebase { previousSteps, lastKnownSteps in
                        self.fetchStepCountAndUpdate(previousSteps: previousSteps, lastKnownSteps: lastKnownSteps)
                    }
                    self.loadPreviousCaloriesFromFirebase { previousCalories, lastKnownCalories in
                        self.fetchCaloriesAndUpdate(previousCalories: previousCalories, lastKnownCalories: lastKnownCalories)
                    }
                    self.loadPreviousPointsFromFirebase { previousPoints in
                        self.totalPoints = previousPoints  // Set the total points when loaded
                    }
                } else {
                    print("HealthKit authorization failed: \(String(describing: error))")
                }
            }
        }
        
        func loadPreviousPointsFromFirebase(completion: @escaping (Int) -> Void) {
            let db = Firestore.firestore()
            
            db.collection("User").document(self.email!).getDocument { (document, error) in
                if let document = document, document.exists {
                    let totalPoints = document.data()?["totalPoints"] as? Int ?? 0
                    completion(totalPoints)
                } else {
                    print("Document does not exist or error: \(String(describing: error))")
                    completion(0) // Assume 0 points if the document doesn't exist
                }
            }
        }
        
        func calculateAndSavePoints(for newSteps: Int, and newCalories: Double) {
            let pointsFromSteps = newSteps / 100  // Example: 1 point for every 100 steps
            let pointsFromCalories = Int(newCalories) / 100  // Example: 1 point for every 100 kcal

            totalPoints += pointsFromSteps + pointsFromCalories

            // Update the points label
            DispatchQueue.main.async {
                self.points.text = "\(self.totalPoints) points"
            }

            // Save the total points to Firebase
            self.saveTotalPointsToFirebase()
        }

        func saveTotalPointsToFirebase() {
            let db = Firestore.firestore()
            let userDocument = db.collection("User").document(email!)
            
            userDocument.setData([
                "totalPoints": totalPoints
            ], merge: true) { error in
                if let error = error {
                    print("Error writing total points to Firestore: \(error)")
                } else {
                    print("Total points successfully written to Firestore!")
                }
            }
        }
        
        // MARK: - Steps Logic
        
        func loadPreviousStepsFromFirebase(completion: @escaping (Int, Int) -> Void) {
            let db = Firestore.firestore()
            
            db.collection("User").document(self.email!).getDocument { (document, error) in
                if let document = document, document.exists {
                    let totalSteps = document.data()?["totalSteps"] as? Int ?? 0
                    let lastKnownSteps = document.data()?["lastKnownSteps"] as? Int ?? 0
                    completion(totalSteps, lastKnownSteps)
                } else {
                    print("Document does not exist or error: \(String(describing: error))")
                    completion(0, 0) // Assume 0 steps if the document doesn't exist
                }
            }
        }
        
        func fetchStepCountAndUpdate(previousSteps: Int, lastKnownSteps: Int) {
            let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
            
            let startOfDay = Calendar.current.startOfDay(for: Date())
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
            
            let query = HKStatisticsQuery(quantityType: stepCountType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                guard let result = result, let sum = result.sumQuantity() else {
                    print("No step count available")
                    return
                }

                let currentSteps = Int(sum.doubleValue(for: HKUnit.count()))
                let stepsSinceLastCheck = currentSteps - lastKnownSteps

                if stepsSinceLastCheck > 0 {
                    let newTotalSteps = previousSteps + stepsSinceLastCheck

                    // Update the UI
                    DispatchQueue.main.async {
                        self.steps.text = "\(newTotalSteps) steps"
                    }

                    // Save the new total steps and last known steps back to Firebase
                    self.saveTotalStepsToFirebase(totalSteps: newTotalSteps, lastKnownSteps: currentSteps)

                    // Calculate and save points based on steps and calories
                    self.calculateAndSavePoints(for: stepsSinceLastCheck, and: 0)
                }
            }
            
            healthStore.execute(query)
        }

        func saveTotalStepsToFirebase(totalSteps: Int, lastKnownSteps: Int) {
            let db = Firestore.firestore()
            let userDocument = db.collection("User").document(email!)
            
            userDocument.setData([
                "totalSteps": totalSteps,
                "lastKnownSteps": lastKnownSteps
            ], merge: true) { error in
                if let error = error {
                    print("Error writing total steps to Firestore: \(error)")
                } else {
                    print("Total steps and last known steps successfully written to Firestore!")
                }
            }
        }

        // MARK: - Calories Logic
        
        func loadPreviousCaloriesFromFirebase(completion: @escaping (Double, Double) -> Void) {
            let db = Firestore.firestore()
            
            db.collection("User").document(self.email!).getDocument { (document, error) in
                if let document = document, document.exists {
                    let totalCalories = document.data()?["totalCalories"] as? Double ?? 0.0
                    let lastKnownCalories = document.data()?["lastKnownCalories"] as? Double ?? 0.0
                    completion(totalCalories, lastKnownCalories)
                } else {
                    print("Document does not exist or error: \(String(describing: error))")
                    completion(0.0, 0.0) // Assume 0 calories if the document doesn't exist
                }
            }
        }
        
        func fetchCaloriesAndUpdate(previousCalories: Double, lastKnownCalories: Double) {
            let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
            
            let startOfDay = Calendar.current.startOfDay(for: Date())
            let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: Date(), options: .strictStartDate)
            
            let query = HKStatisticsQuery(quantityType: energyType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
                guard let result = result, let sum = result.sumQuantity() else {
                    print("No calorie data available")
                    return
                }

                let currentCalories = sum.doubleValue(for: HKUnit.kilocalorie())
                let caloriesSinceLastCheck = currentCalories - lastKnownCalories

                if caloriesSinceLastCheck > 0 {
                    let newTotalCalories = previousCalories + caloriesSinceLastCheck

                    // Update the UI
                    DispatchQueue.main.async {
                        self.calories.text = "\(Int(newTotalCalories)) kcal"
                    }

                    // Save the new total calories and last known calories back to Firebase
                    self.saveTotalCaloriesToFirebase(totalCalories: newTotalCalories, lastKnownCalories: currentCalories)

                    // Calculate and save points based on calories
                    self.calculateAndSavePoints(for: 0, and: caloriesSinceLastCheck)
                }
            }
            
            healthStore.execute(query)
        }

        func saveTotalCaloriesToFirebase(totalCalories: Double, lastKnownCalories: Double) {
            let db = Firestore.firestore()
            let userDocument = db.collection("User").document(email!)
            
            userDocument.setData([
                "totalCalories": totalCalories,
                "lastKnownCalories": lastKnownCalories
            ], merge: true) { error in
                if let error = error {
                    print("Error writing total calories to Firestore: \(error)")
                } else {
                    print("Total calories and last known calories successfully written to Firestore!")
                }
            }
        }
    
    @IBAction func backToHome(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
