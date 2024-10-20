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
    var email: String?
    
    var stepAnchor: HKQueryAnchor?
    var energyAnchor: HKQueryAnchor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestHealthKitAuthorization()
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
            } else {
                print("HealthKit authorization failed: \(String(describing: error))")
            }
        }
    }
    
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
                        self.points.text = "\(newTotalSteps / 100)"
                    }

                    // Save the new total steps and last known steps back to Firebase
                    self.saveTotalStepsToFirebase(totalSteps: newTotalSteps, lastKnownSteps: currentSteps)
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
    
    
    @IBAction func backToHome(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
