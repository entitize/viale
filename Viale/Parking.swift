//
//  Parking.swift
//  Viale
//
//  Created by Kai Nakamura on 5/26/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import Foundation
import MapKit
import Firebase

class Parking {
    
    var name : String!
    var description : String!

    //Location
    var addressString : String!
    var coordinate : CLLocationCoordinate2D!
    
    //Images
    var parkingImageURL : String!
    
    //Owner Data
    var ownerUID : String!
    
    //Interval Data
    var intervals : [String:Bool]!
    var totalIntervals : Int!
    
    //Rates $
    var averageRate : Float!
    var totalRates : Float!
    
    //Stars
    var totalStars : Int!
    var totalRatesAmount : Float!
    
    //Local Properties
    private var parkingImage : UIImage?
    
    init(snapshot:[String:AnyObject]) {
        
        self.name = snapshot["name"] as? String
        self.addressString = snapshot["addressString"] as! String
        self.averageRate = snapshot["averageRate"] as! Float
        self.description = snapshot["description"] as! String
        self.ownerUID = snapshot["ownerUID"] as! String
        self.parkingImageURL = snapshot["parkingImageURL"] as! String
        self.totalRates = snapshot["totalRates"] as! Float
        self.totalRatesAmount = snapshot["totalRates"] as! Float
        
        if let _intervals = snapshot["intervals"] as? [String:Bool] {
            self.intervals = _intervals
        } else {
            self.intervals = [:]
        }
    
    }
    
    func getParkingImage(completion: @escaping (_ image: UIImage) -> Void) {
        
        if let image = parkingImage {
            completion(image)
        } else {
            DataService.ds.downloadImage(withUrl: parkingImageURL, completion: { (image) in
                self.parkingImage = image
                completion(image)
            })
            
        }
        
    }
    
    
    
    
}
