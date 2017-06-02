//
//  IntervalCell.swift
//  Viale
//
//  Created by Kai Nakamura on 5/29/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import Foundation
import UIKit
import FoldingCell
import PKHUD
import Firebase

class IntervalCell : FoldingCell {
    
    var parkingInterval : ParkingInterval?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var totalRevenueLabel: UILabel!
    @IBOutlet weak var fractionLabel: UILabel!
    
    
    var ref : FIRDatabaseReference?
    var handleKey : UInt?
    
    override func awakeFromNib() {
        //Customizations
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        //super.awakeFromNib()
    }
    deinit {
        guard let ref = self.ref, let handleKey = self.handleKey else {
            return
        }
        
        ref.removeObserver(withHandle: handleKey)
        
    }
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        
        let durations = [0.2,0.2,0.2,0.2]
        return durations[itemIndex]
    }
    func setupIntervalListener(intervalKey:String) {
        
        DataService.ds.getIntervalWithUpdates(withKey: intervalKey) { (interval, _, handleKey, ref) in
            self.ref = ref
            self.handleKey = handleKey
            self.parkingInterval = interval
            self.setupViews()
        }
        
        
    }
    func setupViews() {
        
        //Use parkingInterval's data to setup the views
        
        
        //Set up background color and statusLabel text
        guard let remainingSlots = parkingInterval?.availableSlots, let totalSlots = parkingInterval?.totalSlots else {
            HUD.flash(.labeledError(title: "Parsing Error", subtitle: "Internal error with converting slot data"), delay: 2.5)
            return
        }
        
        fractionLabel.text = "\(remainingSlots) / \(totalSlots)"
        
        if (remainingSlots == totalSlots) {
            //Empty
            setCellColor(color: UIColor.init(hex: "#0288D1"))
            statusLabel.text = "Empty, no customers yet"
            
        } else if (remainingSlots >= 1) {
            //There are still some spaces
            setCellColor(color: UIColor.init(hex: "#0097A7"))
            statusLabel.text = "\(remainingSlots) / \(totalSlots) spots remaining"
            
        } else {
            //There are no more spaces
            setCellColor(color: UIColor.init(hex: "#00796B"))
            statusLabel.text = "FULL"
        }
        
        //Setup Title Label
        guard let name = parkingInterval?.name else {
            return
        }
        
        titleLabel.text = name
        
        //Rate Label
        guard let rate = parkingInterval?.ratePerHour else {
            HUD.flash(.labeledError(title: "Parsing Error", subtitle: "Internal error with converting rate data"), delay: 2.5)
            return
        }
        
        startLabel.text = "Start Time: " + DatePickerService.dps.convertDateToString(date: (parkingInterval?.startDate)!)
        endLabel.text = "End Time: " + DatePickerService.dps.convertDateToString(date: (parkingInterval?.endDate)!)
        
        rateLabel.text = "Rate: $\(rate) / hour"
        
        
    }
    func setCellColor(color:UIColor) {
        self.foregroundView.backgroundColor = color
    }
    @IBAction func viewCustomersTapped(_ sender: Any) {
        
    }
    @IBAction func revokeTapped(_ sender: Any) {
        
    }
}
