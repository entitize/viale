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
    var averageRatePerHour : Int?
    var name : String?
    var totalIntervals : Int?
    var description : String?
    
    init(addressString:String,parkingImage:UIImage,rating:CGFloat,coordinate:CLLocationCoordinate2D,ratePerHour:Int,name:String,totalIntervals:Int,description:String,averageRatePerHour:Int) {
        self.addressString = addressString
        self.parkingImage = parkingImage
        self.rating = rating
        self.coordinate = coordinate
        self.totalIntervals = totalIntervals
        self.name = name
        self.description = description
        self.averageRatePerHour = averageRatePerHour
    }
    
}
