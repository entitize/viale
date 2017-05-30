//
//  RentVC.swift
//  Viale
//
//  Created by Kai Nakamura on 5/27/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import UIKit
import DateTimePicker
import PopupDialog


class RentVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var locationNameLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var intervalKeys = [String]()
    
    override func viewDidLoad() {
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NOTIFICATION_KEY_EXIT_RENT), object: nil, queue: nil) { (notification) in
            //Also reload the table view
            self.tableView.reloadData()
            
            self.dismiss(animated: true, completion: nil)
            
            let popup = PopupDialog(title: "Success!", message: "You have successfully scheduled a rent space! View your scheduled rents by clicking the bell icon on the top bar on the map view.")
            
            // Create buttons
            let buttonOne = DefaultButton(title: "Done") { }
            
            popup.addButton(buttonOne)
            self.present(popup, animated: true, completion: nil)
            
        }
        
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        
        guard let selectedParking = RentService.rs.selectedParking else {
            return
        }
        self.locationNameLabel.text = selectedParking.name
        
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
       
        
        if (selectedCell.parkingInterval?.availableSlots == 0) {
            selectedCell.selectionStyle = UITableViewCellSelectionStyle.none
            return
        }
        
        if (selectedCell.alreadyRented == true) {
            selectedCell.selectionStyle = UITableViewCellSelectionStyle.none
            return
        }
        
        RentService.rs.selectedInterval = selectedCell.parkingInterval
        performSegue(withIdentifier: "toNext", sender: nil)
    }
    
    
    
    
}
