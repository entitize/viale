//
//  NewIntervalVC.swift
//  Viale
//
//  Created by Kai Nakamura on 5/28/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import UIKit
import DateTimePicker
import PKHUD
import TextFieldEffects

class NewIntervalVC : UIViewController {
    
    @IBOutlet weak var startDateButton: FancySubmitButton!
    @IBOutlet weak var endDateButton: FancySubmitButton!
    @IBOutlet weak var rateField: KaedeTextField!
    @IBOutlet weak var slotField: KaedeTextField!
    @IBOutlet weak var rulesField: KaedeTextField!
    @IBOutlet weak var nameField: KaedeTextField!
    
    var startDate : Date?
    var endDate : Date?
    
    override func viewDidLoad() {
        self.hideKeyboardWhenTappedAround()
    }
    @IBAction func startTimeTapped(_ sender: Any) {
        
        let picker = DatePickerService.dps.getDatePicker(min: Date(), max: Date().addingTimeInterval(60 * 60 * 24 * 30 * 12))
        picker.completionHandler = { date in
            self.startDateButton.backgroundColor = UIColor(hex: "#90CAF9")
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm aa dd/MM/YYYY"
            self.startDateButton.setTitle("Start: " + formatter.string(from: date), for: .normal)
            self.startDate = date
        }
        
    }
    @IBAction func endTimeTapped(_ sender: Any) {
        
        let picker = DatePickerService.dps.getDatePicker(min: Date(), max: Date().addingTimeInterval(60 * 60 * 24 * 30 * 12))
        picker.completionHandler = { date in
            self.endDateButton.backgroundColor = UIColor(hex: "#90CAF9")
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm aa dd/MM/YYYY"
            self.endDateButton.setTitle("End: " + formatter.string(from: date), for: .normal)
            self.endDate = date
        }
        
    }
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func saveTapped(_ sender: Any) {
        
        HUD.show(.labeledProgress(title: "Uploading", subtitle: "Saving new time interval"))

        //Validate Data
        guard let startDate = startDate, let endDate = endDate else {
            HUD.flash(.labeledError(title: "Dates", subtitle: "Please select your dates by tapping the pink buttons"), delay: 2.5)
            return
        }
        if (rateField.text == "" || slotField.text == "" || rulesField.text == "") {
            HUD.flash(.labeledError(title: "Fields", subtitle: "You must complete all the fields"), delay: 2.5)
            return
        }
        guard let rate = Float(rateField.text!) else {
            HUD.flash(.labeledError(title: "Rate Field Error", subtitle: "You must enter a valid rate amount."), delay: 2.5)
            return
        }
        guard let slots = Int(slotField.text!) else {
            HUD.flash(.labeledError(title: "Slot Field Error", subtitle: "You must enter a valid integer for the number of slots"), delay: 2.5)
            return
        }
        guard let rules = rulesField.text else {
            return
        }
        guard let name = nameField.text else {
            return
        }
        
        //Convert time data to 1970 data
        
        let start1970 = startDate.timeIntervalSince1970
        let end1970 = endDate.timeIntervalSince1970
        
        
        //Upload to firebase under 'Parking Intervals'
        
        let uploadData: Dictionary = [
            "startDateDouble":start1970,
            "endDateDouble":end1970,
            "ratePerHour":rate,
            "rules":rules,
            "availableSlots":slots,
            "totalSlots":slots,
            "name":name
        ] as [String : Any]
        
        let uuid = UUID().uuidString
        
        let intervalRef = DataService.ds.REF_INTERVALS.child(uuid)
        intervalRef.setValue(uploadData) { (error, ref) in
            if (error != nil) {
                HUD.flash(.labeledError(title: "Upload Error", subtitle: "There was an error with uploading the data."), delay: 2.5)
            } else {
                
                //Save this data inside the parking section of database
                
                DataService.ds.REF_USER_PARKINGS.child("intervals").updateChildValues([uuid:true], withCompletionBlock: { (error, ref) in
                    if (error != nil) {
                        HUD.flash(.labeledError(title: "Upload Error", subtitle: "There was an error with uploading the data."), delay: 2.5)
                    } else {
                        
                        //First, download and upload parking's totalRates += 1, totalRatesAmount += ratePerHour
                        
                        
                        DataService.ds.REF_USER_PARKINGS.observeSingleEvent(of: .value, with: { (snapshot) in
                            
                            guard let snap = snapshot.value as? [String:AnyObject] else {
                                
                                HUD.flash(.labeledError(title: "Parsing Error", subtitle: ":("), delay: 2.5)
                                return
                                
                            }
                            
                            //Use 'snap' instead of 'snapshot'
                            
                            guard let totalRates = snap["totalRates"] as? Float, let totalRatesAmount = snap["totalRatesAmount"] as? Float else {
                                HUD.flash(.labeledError(title: "Parsing Error", subtitle: ":( totalRates, totalRatesAmount"), delay: 2.5)
                                return
                            }
                            
                            let newTotalRates = totalRates + 1
                            let newTotalRatesAmount = totalRatesAmount + rate
                            let newAverage = newTotalRatesAmount / newTotalRates
                            
                            //Upload that average to the parking's averageRates
                            DataService.ds.REF_USER_PARKINGS.updateChildValues(["averageRate":newAverage,"totalRates":newTotalRates,"totalRatesAmount":newTotalRatesAmount])
                            
                        })
                        
                        
                        HUD.flash(.success, delay: 2)
                        self.dismiss(animated: true, completion: nil)
                    }
                })
                
                
            }
        }
        
        
    }
    
    
}
