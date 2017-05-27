//
//  ParkingAnnotationView.swift
//  Viale
//
//  Created by Kai Nakamura on 5/27/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import UIKit

class ParkingAnnotationView: MKPinAnnotationView {
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.pinTintColor = .green
        self.isDraggable = false
        self.canShowCallout = true
        self.animatesDrop = true
        
        let infoButton = UIButton.init(type: .detailDisclosure)
        infoButton.frame.size.width = 44
        infoButton.frame.size.height = 44
        
        self.rightCalloutAccessoryView = infoButton
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
