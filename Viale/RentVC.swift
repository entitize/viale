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
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var parkingImage: UIImageView!
    
    override func viewDidLoad() {
        
        locationNameLabel.text = selectedParking.name
        
        //Download user data
        ownerNameLabel.text = "Dummy Name"
        
        
        parkingImage.image = selectedParking.parkingImage
        setupNotifications()
    }
    func setupNotifications() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NOTIFICATION_KEY_EXIT_RENT), object: nil, queue: nil) { (notification) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func startDayTapped(_ sender: Any) {
        let picker = getDatePicker()
        picker.completionHandler = { date in
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm aa dd/MM/YYYY"
            print(formatter.string(from: date))
        }    }
    @IBAction func endDayTapped(_ sender: Any) {
        let picker = getDatePicker()
        picker.completionHandler = { date in
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm aa dd/MM/YYYY"
            print(formatter.string(from: date))
        }
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func nextButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toNext", sender: nil)
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
