//
//  StatsViewController.swift
//  ZvezdaCardio
//
//  Created by Ayush Mahale on 19/10/24.
//

import UIKit
import MapKit

class StatsViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var points: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
