//
//  RentIntervalCell.swift
//  Viale
//
//  Created by Kai Nakamura on 5/29/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import Foundation
import UIKit
import PKHUD
import Firebase

class RentIntervalCell: UITableViewCell {
    
    var parkingInterval : ParkingInterval?
    var alreadyRented = false
    
    
    func setupListeners(key:String) {
        DataService.ds.REF_INTERVALS.child(key).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let snapshot = snapshot.value as? [String: AnyObject] {
                
                guard let startDate = snapshot["startDate"] as? Double, let endDate = snapshot["endDate"] as? Double, let ratePerHour = snapshot["ratePerHour"] as? Float, let slots = snapshot["availableSlots"] as? Int, let rules = snapshot["rules"] as? String, let totalSlots = snapshot["totalSlots"] as? Int else {
                    HUD.flash(.labeledError(title: "Data Parsing Error", subtitle: "There was an internal error regarding the parsing of downloaded interval data"), delay: 2.5)
                    return
                }
                
                
                //Create the parking interval
                self.parkingInterval = ParkingInterval(startNumber: startDate, endNumber: endDate, ratePerHour: ratePerHour, rules: rules, availableSlots: slots, totalSlots: totalSlots, intervalKey: key)
                
                let sd = Date(timeIntervalSince1970: startDate)
                let ed = Date(timeIntervalSince1970: endDate)
                let formatter = DateFormatter()
                formatter.dateFormat = "hh:mm aa dd/MM/YYYY"
                self.textLabel?.text = formatter.string(from: sd) + " - " + formatter.string(from: ed)
                self.detailTextLabel?.text = "$\(ratePerHour) / hour"
                
                //Check if full
                if slots == 0 {
                    self.backgroundColor = UIColor.init(hex: "#BDBDBD")
                    self.detailTextLabel?.text = "FULL"
                }
                
                let userUID = DataService.ds.USER_UID
                
                guard let users = snapshot["users"] as? [String: Bool] else {
                    
                    //There are no users, return
                    return
                }
                
                for user in users {
                    if user.value == true {
                        if user.key == userUID {
                            self.alreadyRented = true
                            self.backgroundColor = UIColor.init(hex: "#BDBDBD")
                            self.detailTextLabel?.text = "ALREADY REGISTERED"
                        }
                    }
                }
                
                
            }
            
            
            
            
            
        }) { (error) in
            HUD.flash(.labeledError(title: "Error", subtitle: "Downloading the interval data"), delay: 2.5)
        }
    }
    
    
    
}
