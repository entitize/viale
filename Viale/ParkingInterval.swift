//
//  ParkingInterval.swift
//  Viale
//
//  Created by Kai Nakamura on 5/29/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import Foundation
import UIKit

class ParkingInterval {
    
    var startDate: Date!
    var endDate: Date!
    var name: String!
    var ratePerHour: Float!
    var rules: String!
    var totalSlots: Int!
    var availableSlots: Int!
    
    var intervalKey: String?
    
    var startDateDouble : Double {
        set {
            self.startDate = Date(timeIntervalSince1970: TimeInterval(newValue))
        }
        get {
            if let startDateNumber = self.startDate?.timeIntervalSince1970 {
                return startDateNumber
            } else {
                return 0.0
            }
        }
    }
    var endDateDouble : Double {
        set {
            self.endDate = Date(timeIntervalSince1970: TimeInterval(newValue))
        }
        get {
            if let endDateNumber = self.endDate?.timeIntervalSince1970 {
                return endDateNumber
            } else {
                return 0.0
            }
        }
    }
    
    init(snapshot:[String: AnyObject]) {
        
        self.name = snapshot["name"] as! String
        self.startDateDouble = snapshot["startDateDouble"] as! Double
        self.endDateDouble = snapshot["endDateDouble"] as! Double
        self.availableSlots = snapshot["availableSlots"] as! Int
        self.totalSlots = snapshot["totalSlots"] as! Int
        self.ratePerHour = snapshot["ratePerHour"] as! Float
        self.rules = snapshot["rules"] as! String
        
    }
    
    
    
    
}
