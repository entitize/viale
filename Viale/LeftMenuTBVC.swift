//
//  LeftMenuTBVC.swift
//  Viale
//
//  Created by Kai Nakamura on 5/26/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import UIKit
import Firebase

class LeftMenuTBVC: UITableViewController {
        

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return UserDriver.currentUser.fullName
    
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedIndex = (indexPath as NSIndexPath).row
        
        
        if selectedIndex == 0 {
            
            dismiss(animated: true, completion: nil)
        } else if selectedIndex == 3 {
            dismiss(animated: true, completion: { 
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_KEY_MANAGE_DRIVEWAY), object: nil)
            })
            
        
        } else if selectedIndex == 7 {
            
            //Logout User
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_KEY_LOGOUT_USER), object: nil)
        } else if selectedIndex == 1 {
            
            dismiss(animated: true, completion: { 
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_KEY_OPEN_SCHEDULE), object: nil)
            })
            //Open our schedule
            
            
        }
        
    }
    
    
}
