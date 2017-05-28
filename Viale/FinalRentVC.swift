//
//  FinalRentVC.swift
//  Viale
//
//  Created by Kai Nakamura on 5/27/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import Foundation
import UIKit
import SwiftSignatureView
import PKHUD

class FinalRentVC: UIViewController, SwiftSignatureViewDelegate {
    
    var signed = false
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var signatureView: SwiftSignatureView!
    
    
    override func viewDidLoad() {
        self.signatureView.delegate = self
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
            dismiss(animated: true, completion: { 
                NotificationCenter.default.post(name: NSNotification.Name.init(NOTIFICATION_KEY_EXIT_RENT), object: nil)
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
