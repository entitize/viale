//
//  UserDriver.swift
//  Viale
//
//  Created by Kai Nakamura on 5/26/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import Foundation

class UserDriver {
    
    static var currentUser : UserDriver!
    
    var fullName : String!
    var phoneNumber : String!
    
    var avatarImageURL : String!
    var carImageURL : String!
    
    var parking : Parking?
    var hasDriveway : Bool!
    
    init(snapshot:[String:AnyObject]) {
        
        self.fullName = snapshot["fullName"] as! String
        self.hasDriveway = snapshot["hasDriveway"] as! Bool
        self.phoneNumber = snapshot["phoneNumber"] as! String
        self.avatarImageURL = snapshot["avatarImageURL"] as! String
        self.carImageURL = snapshot["carImageURL"] as! String
        
    }
    
    
    
}
