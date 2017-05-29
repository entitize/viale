//
//  UserDriver.swift
//  Viale
//
//  Created by Kai Nakamura on 5/26/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import Foundation

class UserDriver {
    
    static var currentUser = UserDriver(fullName: "", avatarImage: UIImage(named: "add_feeling_btn")!, carImage: UIImage(named: "Swift_logo.svg")!, phoneNumber: "0000000000")
    
    //All
    var fullName : String?
    var avatarImage : UIImage?
    var phoneNumber : String?
    var carImage : UIImage?
    
    var parking : Parking?
    var hasDriveway : Bool?
    
    init(fullName:String,avatarImage:UIImage,carImage:UIImage,phoneNumber:String,parking:Parking? = nil, hasDriveway:Bool? = false) {
        
        self.fullName = fullName
        self.avatarImage = avatarImage
        self.carImage = carImage
        self.phoneNumber = phoneNumber
        self.parking = parking
        self.hasDriveway = hasDriveway
    }
    
    
    
    
    
}
