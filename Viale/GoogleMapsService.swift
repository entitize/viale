//
//  GoogleMapsService.swift
//  Viale
//
//  Created by Kai Nakamura on 5/27/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import Foundation
import SwiftyJSON
import MapKit

class GoogleMapsService {
    
    static let gm = GoogleMapsService()
    
    let baseUrl = "https://maps.googleapis.com/maps/api/geocode/json?"
    let apikey = "AIzaSyCvmOCn6P4jfb77qsnHuE5xg0HS5Pcghmg"
    let dummyCoordinate = CLLocationCoordinate2D.init(latitude: 0, longitude: 0)
    let dummyAddress = "0000"
    
    func getLatLng(addressString: String) -> (location:CLLocationCoordinate2D,formattedAdress:String,isError:Bool) {
        
        let newString = addressString.replacingOccurrences(of: " ", with: "+")
        
        let url = URL(string: "\(baseUrl)address=\(newString)&key=\(apikey)")
        var data : Data?
        
        do {
            try data = Data(contentsOf: url!)
        } catch {
            print("KAI: Error with maps \(error)")
        }
        
        if let data = data {
            let json = JSON(data: data)
            
            print("KAI: \(json["results"][0])")
            
            let result = json["results"][0]["geometry"]["location"]
            
            guard let latitude = CLLocationDegrees.init(result["lat"].stringValue), let longitude = CLLocationDegrees.init(result["lng"].stringValue) else {
                print("KAI: latitude longitude error")
                return (dummyCoordinate,dummyAddress,true)
            }
            
            //Success!
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            return (coordinate,json["results"][0]["formatted_address"].stringValue,false)
        } else {
            print("KAI: Error with finding the map loction data")
            return (dummyCoordinate,dummyAddress,true)
        }
        
    }
    
    
}
