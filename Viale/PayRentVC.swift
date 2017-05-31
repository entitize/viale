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
                
                //Upload the user UID under 'users' inside the intervalRef
                let userUID = DataService.ds.USER_UID
                intervalRef.child("users").child(userUID).setValue(true)
                
                //Success
                self.performSegue(withIdentifier: "toNext", sender: nil)
                
            }, withCancel: { (error) in
                HUD.flash(.labeledError(title: "Upload Error", subtitle: "There was an error with downloading the slots data"), delay: 2.5)
            })
            
            
        } else {
            HUD.flash(.labeledError(title: "Signature Required", subtitle: "Please Sign in the Gray Box to Confirm"),delay:1)
        }
    }
    func swiftSignatureViewDidTapInside(_ view: SwiftSignatureView) {
        signed = true
        
    }
    func swiftSignatureViewDidPanInside(_ view: SwiftSignatureView) {
        signed = true
    }
    
    
}
