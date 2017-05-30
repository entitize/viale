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
    
    override func awakeFromNib() {
        //Customizations
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        super.awakeFromNib()
    }
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        
        let durations = [0.2,0.2,0.2,0.2]
        return durations[itemIndex]
    }
    func setupIntervalListener(intervalKey:String) {
        
        DataService.ds.REF_INTERVALS.child(intervalKey).observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapshot = snapshot.value as? [String: AnyObject] {
                
                guard let startDate = snapshot["startDate"] as? Double, let endDate = snapshot["endDate"] as? Double, let ratePerHour = snapshot["ratePerHour"] as? Float else {
                    HUD.flash(.labeledError(title: "Data Parsing Error", subtitle: "There was an internal error regarding the parsing of downloaded interval data"), delay: 2.5)
                    return
                }
                guard let slots = snapshot["availableSlots"] as? Int else {
                    HUD.flash(.labeledError(title: "Data Parsing Error", subtitle: "There was an internal error regarding the parsing of downloaded interval data"), delay: 2.5)
                    return
                }
                guard let rules = snapshot["rules"] as? String else {
                    HUD.flash(.labeledError(title: "Data Parsing Error", subtitle: "There was an internal error regarding the parsing of downloaded interval data"), delay: 2.5)
                    return
                }
                guard let totalSlots = snapshot["totalSlots"] as? Int else {
                    HUD.flash(.labeledError(title: "Data Parsing Error", subtitle: "There was an internal error regarding the parsing of downloaded interval data"), delay: 2.5)
                    return
                }
                
                //Create the parking interval
                self.parkingInterval = ParkingInterval(startNumber: startDate, endNumber: endDate, ratePerHour: ratePerHour, rules: rules, availableSlots: slots, totalSlots: totalSlots, intervalKey: intervalKey)
                
                self.setupViews()
                
            }
        }) { (error) in
            HUD.flash(.labeledError(title: "Get Recked", subtitle: "360 No Scope"), delay: 2.5)
        }
        
    }
    func setupViews() {
        //Use parkingInterval's data to setup the views
        
        
        //Set up background color and statusLabel text
        guard let remainingSlots = parkingInterval?.availableSlots, let totalSlots = parkingInterval?.totalSlots else {
            HUD.flash(.labeledError(title: "Parsing Error", subtitle: "Internal error with converting slot data"), delay: 2.5)
            return
        }
        
        if (remainingSlots == totalSlots) {
            //Empty
            setCellColor(color: UIColor.init(hex: "#66BB6A"))
            statusLabel.text = "Empty, no customers yet"
            
        } else if (remainingSlots >= 1) {
            //There are still some spaces
            setCellColor(color: UIColor.init(hex: "#5C6BC0"))
            statusLabel.text = "\(remainingSlots) / \(totalSlots) spots remaining"
            
        } else {
            //There are no more spaces
            setCellColor(color: UIColor.init(hex: "#7E57C2"))
            statusLabel.text = "FULL"
        }
        
        
        
        //Setup Title Label
        guard let startDate = parkingInterval?.startDate, let endDate = parkingInterval?.endDate else {
            HUD.flash(.labeledError(title: "Parsing Error", subtitle: "Internal error with converting date data"), delay: 2.5)
            return
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm aa dd/MM/YYYY"
        titleLabel.text = formatter.string(from: startDate) + " - " + formatter.string(from: endDate)
        
        //Rate Label
        guard let rate = parkingInterval?.ratePerHour else {
            HUD.flash(.labeledError(title: "Parsing Error", subtitle: "Internal error with converting rate data"), delay: 2.5)
            return
        }
        
        rateLabel.text = "$\(rate) / hour"
        
        
    }
    func setCellColor(color:UIColor) {
        self.foregroundView.backgroundColor = color
    }
    @IBAction func viewCustomersTapped(_ sender: Any) {
        
    }
    @IBAction func revokeTapped(_ sender: Any) {
        
    }
}
