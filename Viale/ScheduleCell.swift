//
//  ScheduleCell.swift
//  Viale
//
//  Created by Kai Nakamura on 6/2/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import UIKit
import FoldingCell

class ScheduleCell : FoldingCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var myAddressString = ""
    var placeNameString = ""
    
    override func awakeFromNib() {
        //Customizations
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        super.awakeFromNib()
    }
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        
        let durations = [0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2,0.2]
        return durations[itemIndex]
    }
    func setupIntervalListener(intervalKey:String) {
        
        DataService.ds.getUserInterval(withKey: intervalKey) { (userInterval) in
            
            self.titleLabel.text = userInterval.placeName
            self.userNameLabel.text = "Driveway Owner: " + userInterval.ownerName
            self.startLabel.text = "Start: " + DatePickerService.dps.convertDateToString(date: userInterval.startDate)
            self.endLabel.text = "End: " + DatePickerService.dps.convertDateToString(date: userInterval.endDate)
            self.phoneNumberLabel.text = "Phone: " + userInterval.phoneNumber
            self.addressLabel.text = userInterval.addressString
            self.myAddressString = userInterval.addressString
            self.placeNameString = userInterval.placeName
        }
        
    }
    @IBAction func getDirectionsTapped(_ sender: Any) {
        let res = GoogleMapsService.gm.getLatLng(addressString: self.myAddressString)
        if res.isError == false {
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: res.location, addressDictionary:nil))
            mapItem.name = self.placeNameString
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }
    }
    
}
