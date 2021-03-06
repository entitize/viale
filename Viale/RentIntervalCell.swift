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
        
        DataService.ds.getInterval(withKey: key) { (interval,_) in
            self.parkingInterval = interval
            
            let startDateString = DatePickerService.dps.convertDateToString(date: interval.startDate)
            let endDateString = DatePickerService.dps.convertDateToString(date: interval.endDate)
            
            self.textLabel?.text = startDateString + " - " + endDateString
            
            self.detailTextLabel?.text = "$\(interval.ratePerHour!) / hour"
            
            //Check if full
            if interval.availableSlots == 0 {
                self.backgroundColor = UIColor.init(hex: "#BDBDBD")
                self.detailTextLabel?.text = "FULL"
            }
            
            let userUID = DataService.ds.USER_UID
            
            if let userIds = interval.userIds {
                for userId in userIds {
                    
                    if userId == userUID {
                        self.alreadyRented = true
                        self.backgroundColor = UIColor.init(hex: "#BDBDBD")
                        self.detailTextLabel?.text = "ALREADY REGISTERED"
                    }
                    
                }
            }
            
            
            
        }
    }
    
    
}
