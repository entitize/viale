//
//  UserDriver.swift
//  Viale
//
//  Created by Kai Nakamura on 5/26/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import Foundation

class UserDriver {
    
    //All
    var fullName : String?
    var avatarImage : UIImage?
    
    //Driver Specific
    var carImage : UIImage?
    
    
    //Owner Specific

    //In the future have an identifier to the home instead of the home object itself
    
    init(fullName:String,avatarImage:UIImage,carImage:UIImage) {
        self.fullName = fullName
        self.avatarImage = avatarImage
        self.carImage = carImage
    }
    
    
    
    
    
}
