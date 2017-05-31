//
//  SearchAnnotation.swift
//  Viale
//
//  Created by Kai Nakamura on 5/27/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import Foundation
import MapKit

class SearchAnnotation: NSObject, MKAnnotation {
    var coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D {
        return coord
    }
    
    
}
