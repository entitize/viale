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
    var coordinate: CLLocationCoordinate2D {
        return coord
    }
    
    var parking : Parking? {
        didSet {
            
            if let p = parking {
                
                //Download user
                self.title = p.addressString
                
                self.subtitle = p.name
                
                if let c = p.coordinate {
                    self.coord = c
                }
                
            }
            
        }
    }
    
    
    
}
