//
//  ParkingAnnotation.swift
//  Viale
//
//  Created by Kai Nakamura on 5/25/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ParkingAnnotation: NSObject, MKAnnotation {
    
    private var coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    var title: String?
    var subtitle: String?
    
    var parking: Parking?
    
    var coordinate: CLLocationCoordinate2D {
        return coord
    }
    init(parking:Parking) {
        
        self.parking = parking
        self.title = parking.name
        self.subtitle = "$\(parking.averageRate!) / hour"
        self.coord = parking.coordinate
        
    }

    
    
    
}
