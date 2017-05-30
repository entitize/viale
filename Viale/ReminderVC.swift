//
//  ReminderVC.swift
//  Viale
//
//  Created by Kai Nakamura on 5/29/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import Foundation
import UIKit
import PopupDialog
import PKHUD

class ReminderVC: UIViewController {
    
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var scheduleReminderButton: FancySubmitButton!
    @IBOutlet weak var whenToArriveLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var tillLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    
    var selectedRemindedDate : Date?
    
    override func viewDidLoad() {
        
        guard let selectedParking = RentService.rs.selectedParking, let selectedInterval = RentService.rs.selectedInterval else {
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm aa dd/MM/YYYY"

        
        locationNameLabel.text = selectedParking.name
        whenToArriveLabel.text = "You should arrive to your destination at: " + formatter.string(from: selectedInterval.startDate!)
        
        addressLabel.text = selectedParking.addressString
        fromLabel.text = formatter.string(from: selectedInterval.startDate!)
        tillLabel.text = formatter.string(from: selectedInterval.endDate!)
        DataService.ds.REF_USERS.child(selectedParking.ownerUID!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.value as? [String: AnyObject] {
                if let fullName = snapshot["fullName"] as? String {
                    self.ownerNameLabel.text = fullName
                }
            }
        })
        

    }
    @IBAction func chooseReminderTimeTapped(_ sender: Any) {
        
        guard let selectedInterval = RentService.rs.selectedInterval else {
            return
        }
        
        let earlyDate = Date(timeInterval: -60 * 60 * 12, since: selectedInterval.startDate!)
        let lateDate = Date(timeInterval: -60 * 7, since: selectedInterval.endDate!)

        let picker = DatePickerService.dps.getDatePicker(min: earlyDate, max: lateDate)
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm aa dd/MM/YYYY"
        
        picker.completionHandler = { date in
            
            self.scheduleReminderButton.setTitle(formatter.string(from: date), for: .normal)
            self.scheduleReminderButton.backgroundColor = UIColor(hex: "#90CAF9")
            self.selectedRemindedDate = date
            
        }
        
        
    }
    @IBAction func cancelTapped(_ sender: Any) {
        
        //Display the popup accordingly
        let popup = PopupDialog(title: "Are you sure?", message: "Viale will not send you a notification. We recommend that you should write it in your agenda or set an alarm on your watch.")
        
        // Create buttons
        let noButton = DefaultButton(title: "Cancel") {
            //Do nothing
        }
        let yesButton = DefaultButton(title: "Yes, I do not need a reminder") {
            self.superDismiss()
        }
        
        popup.addButtons([noButton,yesButton])
        self.present(popup, animated: true, completion: nil)
        
    }
    @IBAction func setReminderTapped(_ sender: Any) {
        
        guard let date = selectedRemindedDate else {
            HUD.flash(.labeledError(title: "Date", subtitle: "Please select a reminder date"), delay: 2.5)
            return
        }
        
    }
    func superDismiss() {
        self.dismiss(animated: true) { 
            NotificationCenter.default.post(name: NSNotification.Name.init(NOTIFICATION_KEY_EXIT_RENT), object: nil, userInfo: nil)
        }
    }
    
}
