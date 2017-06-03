//
//  PayRentVC.swift
//  Viale
//
//  Created by Kai Nakamura on 5/27/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import Foundation
import UIKit
import SwiftSignatureView
import PKHUD
import Firebase

class PayRentVC: UIViewController, SwiftSignatureViewDelegate {
    
    var signed = false
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var signatureView: SwiftSignatureView!
    @IBOutlet weak var locationNameLabel: UILabel!
    
    override func viewDidLoad() {
        self.signatureView.delegate = self
        locationNameLabel.text = RentService.rs.selectedParking?.name
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NOTIFICATION_KEY_EXIT_RENT), object: nil, queue: nil) { (notification) in
            self.dismiss(animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func cleaButtonTapped(_ sender: Any) {
        signatureView.clear()
        signed = false
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func rentButtonTapped(_ sender: Any) {
        if (signed == true) {
            
            //Subtract 1 from totalParkings
            guard let intervalKey = RentService.rs.selectedInterval?.intervalKey else {
                return
            }
            let intervalRef = DataService.ds.REF_INTERVALS.child(intervalKey)
            let intervalSlotsRef = intervalRef.child("availableSlots")
                
            intervalSlotsRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let valString = snapshot.value as? Int else {
                    return
                }
                let value = valString - 1
                intervalSlotsRef.setValue(value)
                
                //Generate random key
                let randomKey = NSUUID().uuidString
                self.uploadUserInterval(withKey: randomKey, withRefToInterval: intervalRef)
            
                
            }, withCancel: { (error) in
                HUD.flash(.labeledError(title: "Upload Error", subtitle: "There was an error with downloading the slots data"), delay: 2.5)
            })
            
            
        } else {
            HUD.flash(.labeledError(title: "Signature Required", subtitle: "Please Sign in the Gray Box to Confirm"),delay:1)
        }
    }
    func uploadUserInterval(withKey key:String, withRefToInterval intervalRef:FIRDatabaseReference) {
        
        HUD.show(.progress)
        
        let userUID = DataService.ds.USER_UID
        
        //Construct the Firebase UserInterval Object for uploading
        
        //Convert dates to doubles
        
        let startDateDouble = RentService.rs.selectedStartDate?.timeIntervalSince1970
        let endDateDouble = RentService.rs.selectedEndDate?.timeIntervalSince1970
        
        
        let uploadData : [String:AnyObject] = [
            "startDateDouble":startDateDouble as AnyObject,
            "endDateDouble":endDateDouble as AnyObject,
            "ownerKey":userUID as AnyObject,
            "paidAmount":RentService.rs.totalValue as AnyObject,
            "addressString":RentService.rs.selectedParking?.addressString as AnyObject,
            "ownerName":RentService.rs.selectedOwner?.fullName as AnyObject,
            "phoneNumber":RentService.rs.selectedOwner?.phoneNumber as AnyObject
        ]
        
        //Upload the information
        
        DataService.ds.REF_USER_INTERVALS.child(key).updateChildValues(uploadData) { (error, _) in
            
            if (error != nil) {
                HUD.flash(.labeledError(title: "Upload Error", subtitle: "There was an error with uploading the user interval data"),delay:1)
            } else {
                
                //Store the key of the new UserInterval intside the ParkingInterval
            
                intervalRef.child("userIntervals").child(key).setValue(true, withCompletionBlock: { (error, _) in
                    
                    if (error != nil) {
                        HUD.flash(.labeledError(title: "Upload Error", subtitle: "There was an error with setting the userIntervals key data"),delay:1)
                    } else {
                        
                        
                        //Also store the customer uid within the usersIds of the ParkingInterval
                        intervalRef.child("userIds").child(DataService.ds.USER_UID).setValue(true, withCompletionBlock: { (error, _) in
                            
                            if (error != nil) {
                                
                                HUD.flash(.labeledError(title: "Upload Error", subtitle: "There was an error with setting the userIntervals key data"),delay:1)
                                
                            } else {
                                
                                //Also put the key inside the currentUser information
                                DataService.ds.REF_USER_CURRENT.child("schedule").child(key).setValue(true, withCompletionBlock: { (error, _) in
                                    if (error != nil) {
                                        HUD.flash(.labeledError(title: "Upload Error", subtitle: "There was an error with setting the userIntervals key data"),delay:1)
                                    } else {
                                        
                                        HUD.hide()
                                        self.performSegue(withIdentifier: "toNext", sender: nil)
                                    }
                                })
                                
                                
                            }
                            
                            
                        })
                        
                        
                        
                        
                        
                    }
                    
                })
                
            }
            
        }
        
    }
    
    func swiftSignatureViewDidTapInside(_ view: SwiftSignatureView) {
        signed = true
        
    }
    func swiftSignatureViewDidPanInside(_ view: SwiftSignatureView) {
        signed = true
    }
    
    
}
