//
//  DataService.swift
//  Viale
//
//  Created by Kai Nakamura on 5/25/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import Foundation
import Firebase

let DB_BASE = FIRDatabase.database().reference()

class DataService {
    
    static let ds = DataService()
    
    private var _REF_USERS = DB_BASE.child("users")
    
    func createFirebaseDBUser(uid:String, userData: Dictionary<String,String>) {
        _REF_USERS.child(uid).updateChildValues(userData)
    }
    
    
}
