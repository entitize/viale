//
//  LeftMenuTBVC.swift
//  Viale
//
//  Created by Kai Nakamura on 5/26/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import UIKit

class LeftMenuTBVC: UITableViewController {
    
    override func viewDidLoad() {
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedIndex = (indexPath as NSIndexPath).row
        
        if selectedIndex == 6 {
            
            //Logout User
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION_KEY_LOGOUT_USER), object: nil)
        }
        
    }
    
    
}
