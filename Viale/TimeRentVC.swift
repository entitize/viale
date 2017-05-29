//
//  TimeRentVC.swift
//  Viale
//
//  Created by Kai Nakamura on 5/29/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import Foundation
import UIKit
import PKHUD

class TimeRentVC: UIViewController {
    
    @IBOutlet weak var startDateBtn: FancySubmitButton!
    @IBOutlet weak var endDateBtn: FancySubmitButton!
    @IBOutlet weak var totalLabel: UILabel!

    var minDate : Date?
    var maxDate : Date?
    
    var selectedStartDate : Date?
    var selectedEndDate : Date?
    
    override func viewDidLoad() {
        
        guard let selectedInterval = RentService.rs.selectedInterval else {
            return
        }
        minDate = selectedInterval.startDate
        maxDate = selectedInterval.endDate
        
        
    }
    
    @IBAction func startDateTapped(_ sender: Any) {
        let picker = DatePickerService.dps.getDatePicker(min: minDate!, max: maxDate!)
        picker.completionHandler = { date in
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm aa dd/MM/YYYY"
            self.startDateBtn.setTitle("Start: " + formatter.string(from: date), for: .normal)
            self.selectedStartDate = date
            self.startDateBtn.backgroundColor = UIColor.init(hex: "#90CAF9")
            self.updateTotalLabel()
        }
        
        
    }
    
    @IBAction func endDateTapped(_ sender: Any) {
        let picker = DatePickerService.dps.getDatePicker(min: minDate!, max: maxDate!)
        picker.completionHandler = { date in
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm aa dd/MM/YYYY"
            self.endDateBtn.setTitle("End: " + formatter.string(from: date), for: .normal)
            self.selectedEndDate = date
            self.endDateBtn.backgroundColor = UIColor.init(hex: "#90CAF9")
            self.updateTotalLabel()
        }
        
    }
    func updateTotalLabel() {
        //rate * hours
        guard let startDate = selectedStartDate, let endDate = selectedEndDate else {
            return
        }
        
        var dHours = endDate.hours(from: startDate)
        if dHours == 0 {
            dHours = 1
        }
        let totalValue = Float(dHours) * (RentService.rs.selectedInterval?.ratePerHour)!
        RentService.rs.totalValue = totalValue
        
        totalLabel.text = "$\(totalValue) per hour"
        
    }
    
    @IBAction func backTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func continueTapped(_ sender: Any) {
        
        //Validate Data, then perform segue
        guard let start = selectedStartDate, let end = selectedStartDate else {
            HUD.flash(.labeledError(title: "Field Error", subtitle: "Please select a start date and an end date"), delay: 2.5)
            return
        }
        
        RentService.rs.selectedStartDate = start
        RentService.rs.selectedEndDate = end
        
        performSegue(withIdentifier: "toNext", sender: nil)
        
    }
}
