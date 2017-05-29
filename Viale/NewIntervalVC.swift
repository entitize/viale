//
//  NewIntervalVC.swift
//  Viale
//
//  Created by Kai Nakamura on 5/28/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import UIKit
import DateTimePicker

class NewIntervalVC : UIViewController {
    
    
    
    override func viewDidLoad() {
        self.hideKeyboardWhenTappedAround()
    }
    @IBAction func startTimeTapped(_ sender: Any) {
        
        let picker = getDatePicker()
        picker.completionHandler = { date in
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm aa dd/MM/YYYY"
            print(formatter.string(from: date))
        }
        
    }
    @IBAction func endTimeTapped(_ sender: Any) {
    }
    @IBAction func cancelTapped(_ sender: Any) {
    }
    @IBAction func saveTapped(_ sender: Any) {
    }
    func getDatePicker() -> DateTimePicker {
        let min = Date()
        let max = Date().addingTimeInterval(60 * 60 * 24 * 4)
        let picker = DateTimePicker.show(minimumDate: min, maximumDate: max)
        picker.highlightColor = UIColor(hex: "#90CAF9")
        picker.darkColor = UIColor.darkGray
        picker.doneButtonTitle = "Choose Time"
        picker.todayButtonTitle = "Today"
        picker.is12HourFormat = true
        picker.dateFormat = "hh:mm aa dd/MM/YYYY"
        return picker
    }
    
}
