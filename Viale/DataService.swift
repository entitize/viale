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
import PKHUD
import Async

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
    private var _REF_CAR_IMAGES = STORAGE_BASE.child("car-images")
    private var _REF_AVATAR_IMAGES = STORAGE_BASE.child("avatar-images")
    
    var REF_PARKING_IMAGES: FIRStorageReference {
        return _REF_PARKING_IMAGES
    }
    var REF_CAR_IMAGES: FIRStorageReference {
        return _REF_CAR_IMAGES
    }
    var REF_AVATAR_IMAGES: FIRStorageReference {
        return _REF_AVATAR_IMAGES
    }
    
    
    //MARK: Local Properties
    
    var USER_UID: String {
        return KeychainWrapper.standard.string(forKey: KEY_UID)!
    }
    
    //MARK: Methods
    
    func setupCurrentUser(completion: @escaping (_ completed:Bool) -> Void) {
        getUserDriver(withUID: USER_UID) { (driver) in
            
            UserDriver.currentUser = driver
            completion(true)
        }
    }
    
    func getInterval(withKey key: String, completion: @escaping (_ parkingInterval: ParkingInterval,_ snapshot:[String:AnyObject]) -> Void) {
        
        DataService.ds.REF_INTERVALS.child(key).observeSingleEvent(of: .value, with: { (snapshot) in
            
            
            guard let intervalData = snapshot.value as? Dictionary<String, AnyObject> else {
                HUD.flash(.labeledError(title: "Error", subtitle: "Parsing Interval Data into simple dictionary"), delay: 2.5)
                return
            }
            let parkingInterval = ParkingInterval(snapshot: intervalData)
            
            parkingInterval.intervalKey = key
            
            completion(parkingInterval,(snapshot.value as? [String: AnyObject])!)
            
        }) { (error) in
            
            HUD.flash(.labeledError(title: "Downloading Error", subtitle: "Error with downloading interval data"), delay: 2.5)
            
        }
        
    }
    func getUserDriver(withUID key: String, completion: @escaping (_ userDriver: UserDriver) -> Void) {
        
        DataService.ds.REF_USERS.child(key).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userData = snapshot.value as? Dictionary<String, AnyObject> else {
                HUD.flash(.labeledError(title: "Error", subtitle: "Parsing User Driver Data into simple dictionary"), delay: 2.5)
                return
            }
            
            let driver = UserDriver(snapshot: userData)
            completion(driver)

        })
        
    }
    func uploadImage(withRef ref:FIRStorageReference, withImage image: UIImage, completion: @escaping (_ downloadURL: String) -> Void) {
        
        //Compress and setup the image data
        if let imgData = UIImageJPEGRepresentation(image, 0.2) {
            let imageUID = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            ref.child(imageUID).put(imgData, metadata: metadata, completion: { (metadata, error) in
                if (error != nil) {
                    HUD.flash(.labeledError(title: "Error", subtitle: "Uploading image data to firebase"), delay: 2.5)
                } else {
                    completion((metadata?.downloadURL()?.absoluteString)!)
                }
            })
            
        }
        
    }
    
    func createFirebaseDBUser(uid:String, userData: Dictionary<String,AnyObject>) {
        _REF_USERS.child(uid).updateChildValues(userData)
    }
    
    
    
    
}
