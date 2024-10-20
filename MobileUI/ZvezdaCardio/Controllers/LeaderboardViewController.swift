//
//  LeaderboardViewController.swift
//  ZvezdaCardio
//
//  Created by Ayush Mahale on 19/10/24.
//

import UIKit
import Firebase
import FirebaseFirestore

class LeaderboardViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var users: [LeaderboardRow] = []
    var email: String?
    let db = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "LeaderboardCell", bundle: nil), forCellReuseIdentifier: "LeaderboardReusableCell")
        loadUsers()
    }
    
    func loadUsers() {
        db.collection("User").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            if let snapshotDocuments = querySnapshot?.documents {
                var x = 0
                for doc in snapshotDocuments {
                    x += 1
                    let data = doc.data()
                    if let nameOfUser = data["name"] as? String,
                       let pointsOfUser = data["totalPoints"] as? Int {

                        let newUser = LeaderboardRow(ranking: x, name: nameOfUser, points: pointsOfUser)
                        self.users.append(newUser)
                        print("User \(newUser.name) with points \(newUser.points) loaded.")
                    } else {
                        print("Error parsing document data")
                    }
                }

                // Sort users in descending order of points
                self.users.sort { $0.points > $1.points }
                
                DispatchQueue.main.async {
                    print("Reloading data")
                    self.tableView.reloadData()
                }
            } else {
                print("No documents found.")
            }
        }
    }
    
    @IBAction func backToStats(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
extension LeaderboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardReusableCell", for: indexPath) as! LeaderboardCell
        
        // Fetch the user for the current row
        let user = users[indexPath.row]
        
        // Set the rank (indexPath.row + 1 gives the rank number)
        cell.rank.text = "\(indexPath.row + 1)"
        
        // Set the name and points
        cell.name.text = user.name
        cell.points.text = "\(user.points)"
        
        return cell
    }
}

extension LeaderboardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
