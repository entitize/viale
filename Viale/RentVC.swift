//
//  RentVC.swift
//  Viale
//
//  Created by Kai Nakamura on 5/27/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import UIKit
import DateTimePicker

class RentVC: UIViewController {
    
    override func viewDidLoad() {
        
        
        //Use selectedParking._
        
        setupNotifications()
        
    }
    func setupNotifications() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NOTIFICATION_KEY_EXIT_RENT), object: nil, queue: nil) { (notification) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func getDatePicker() -> DateTimePicker {
        let min = Date()
        let max = Date().addingTimeInterval(60 * 60 * 24 * 4)
        let picker = DateTimePicker.show(minimumDate: min, maximumDate: max)
        picker.highlightColor = UIColor(hex: "#90CAF9")
        picker.darkColor = UIColor(hex: "#5C6BC0")
        picker.doneButtonTitle = "Choose Time"
        picker.todayButtonTitle = "Today"
        picker.is12HourFormat = true
        picker.dateFormat = "hh:mm aa dd/MM/YYYY"
        return picker
    }
}
