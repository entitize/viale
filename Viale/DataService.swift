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
let STORAGE_BASE = FIRStorage.storage().reference()

class DataService {
    
    static let ds = DataService()
    
    //MARK: Database Properties
    
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_GEOFIRE = DB_BASE.child("geofire")
    private var _REF_PARKINGS = DB_BASE.child("parkings")
    private var _REF_INTERVALS = DB_BASE.child("intervals")
    
    var REF_GEOFIRE: FIRDatabaseReference {
        return _REF_GEOFIRE
    }
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    var REF_PARKINGS: FIRDatabaseReference {
        return _REF_PARKINGS
    }
    var REF_USER_PARKINGS: FIRDatabaseReference {
        return _REF_PARKINGS.child(USER_UID)
    }
    var REF_INTERVALS : FIRDatabaseReference {
        return _REF_INTERVALS
    }
    
    var REF_USER_CURRENT: FIRDatabaseReference {
        let uid = USER_UID
        let user = REF_USERS.child(uid)
        return user
    }
    
    //MARK: Storage Properties
    
    private var _REF_PARKING_IMAGES = STORAGE_BASE.child("parking-images")
    
    var REF_PARKING_IMAGES: FIRStorageReference {
        return _REF_PARKING_IMAGES
    }
    
    
    //MARK: Local Properties
    
    var USER_UID: String {
        return KeychainWrapper.standard.string(forKey: KEY_UID)!
    }
    
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
                if let hasDriveway = snapshot["hasDriveway"] as? Bool {
                    UserDriver.currentUser.hasDriveway = hasDriveway
                }
            }
            
        })
        
    }
    
    func createFirebaseDBUser(uid:String, userData: Dictionary<String,String>) {
        _REF_USERS.child(uid).updateChildValues(userData)
    }
    
    
    
    
}
