//
//  Parking.swift
//  Viale
//
//  Created by Kai Nakamura on 5/26/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import Foundation
import MapKit

class Parking {
    
    var addressString : String?
    var parkingImage : UIImage?
    var rating : CGFloat?
    var coordinate : CLLocationCoordinate2D?
    var owner : UserDriver?
    var ratePerHour : Int?
    var name : String?
    
    init(addressString:String,parkingImage:UIImage,rating:CGFloat,coordinate:CLLocationCoordinate2D,owner:UserDriver,ratePerHour:Int,name:String) {
        self.addressString = addressString
        self.parkingImage = parkingImage
        self.rating = rating
        self.coordinate = coordinate
        self.owner = owner
        self.ratePerHour = ratePerHour
        self.name = name
    }
    
}
