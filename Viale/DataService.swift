//
//  DataService.swift
//  Viale
//
//  Created by Kai Nakamura on 5/25/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import Foundation
import Firebase
import SwiftKeychainWrapper

let DB_BASE = FIRDatabase.database().reference()

class DataService {
    
    static let ds = DataService()
    
    //MARK: Database Properties
    
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_GEOFIRE = DB_BASE.child("geofire")
    
    
    var REF_GEOFIRE: FIRDatabaseReference {
        return _REF_GEOFIRE
    }
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_USER_CURRENT: FIRDatabaseReference {
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS.child(uid!)
        return user
    }
    
    //MARK: Local Properties
    
    //MARK: Methods
    
    func setupGlobalListeners() {
        
        //Setup Listeners
        
        //User itself
        REF_USER_CURRENT.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.value as? [String: AnyObject] {
                if let fullName = snapshot["fullName"] as? String {
                    UserDriver.currentUser.fullName = fullName
                }
                if let phoneNumber = snapshot["phoneNumber"] as? String {
                    UserDriver.currentUser.phoneNumber = phoneNumber
                }
            }
            
        })
        
    }
    
    func createFirebaseDBUser(uid:String, userData: Dictionary<String,String>) {
        _REF_USERS.child(uid).updateChildValues(userData)
    }
    
    
}
