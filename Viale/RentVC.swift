//
//  RentVC.swift
//  Viale
//
//  Created by Kai Nakamura on 5/27/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import UIKit
import DateTimePicker


class RentVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var locationNameLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var intervalKeys = [String]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        guard let selectedParking = RentService.rs.selectedParking else {
            return
        }
        
        intervalKeys = selectedParking.intervalKeys

    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    //MARK: TableView
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RentIntervalCell
        cell.setupListeners(key: intervalKeys[indexPath.row])
        return cell
        
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return intervalKeys.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! RentIntervalCell
        RentService.rs.selectedInterval = selectedCell.parkingInterval
        performSegue(withIdentifier: "toNext", sender: nil)
    }
    
    
    
    
}
