//
//  UserInterval.swift
//  Viale
//
//  Created by Kai Nakamura on 6/1/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import Foundation

class UserInterval {
    
    var startDate: Date!
    var endDate: Date!
    
    var ownerKey: String!
    var paidAmount: Float!
    
    var addressString: String!
    var ownerName: String!
    var phoneNumber: String!
    var placeName: String!
    
    private var owner : UserDriver?
    
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
    func getOwnerData(ownerUID:String,completion:@escaping(_ owner:UserDriver) -> Void) {
    
        if let owner = self.owner {
            
            //It exists so return the owner
            
            completion(owner)
            
        } else {
            
            //Download the owner data from firebase using the key
            DataService.ds.getUserDriver(withUID: ownerUID, completion: { (owner,_) in
                
                self.owner = owner
                completion(owner)
                
            })
            
        }
    
    
    }
    
    init(snapshot:[String: AnyObject]) {
        
        self.startDateDouble = snapshot["startDateDouble"] as! Double
        self.endDateDouble = snapshot["endDateDouble"] as! Double
        self.ownerKey = snapshot["ownerKey"] as! String
        self.paidAmount = snapshot["paidAmount"] as! Float
        self.addressString = snapshot["addressString"] as! String
        self.ownerName = snapshot["ownerName"] as! String
        self.phoneNumber = snapshot["phoneNumber"] as! String
        self.placeName = snapshot["placeName"] as! String
        
    }
    
    
}
