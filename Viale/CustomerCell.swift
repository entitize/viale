//
//  CustomerCell.swift
//  Viale
//
//  Created by Kai Nakamura on 6/1/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import UIKit
import FoldingCell

class CustomerCell : FoldingCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var customerNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var paidAmountLabel: UILabel!
    @IBOutlet weak var firstProfileImage: UIButton!
    @IBOutlet weak var secondProfileImage: UIButton!
    @IBOutlet weak var carImage: UIImageView!
    
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
            
            //Download the customer
            
            DataService.ds.getUserDriver(withUID: userInterval.ownerKey, completion: { (customer) in
                
                //Setup the views
                self.titleLabel.text = customer.fullName
                self.customerNameLabel.text = customer.fullName
                self.phoneNumberLabel.text = "Call: \(customer.phoneNumber!)"
                
                self.startTimeLabel.text = DatePickerService.dps.convertDateToString(date: userInterval.startDate)
                self.endTimeLabel.text = DatePickerService.dps.convertDateToString(date: userInterval.endDate)
                
                //Download the avatar image
                
                DataService.ds.downloadImage(withUrl: customer.avatarImageURL, completion: { (avatarImage) in
                    
                    self.firstProfileImage.setImage(avatarImage, for: .normal)
                    self.secondProfileImage.setImage(avatarImage, for: .normal)
                    
                })
                DataService.ds.downloadImage(withUrl: customer.carImageURL, completion: { (carImage) in
                    self.carImage.image = carImage
                })
                
                self.paidAmountLabel.text = "Paid: $\(userInterval.paidAmount!)"
                
            })
            
        }
        
    }
    
    
}
