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
    private var _REF_USER_INTERVALS = DB_BASE.child("user-intervals")
    
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
    var REF_USER_INTERVALS : FIRDatabaseReference {
        return _REF_USER_INTERVALS
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
    
    //MARK: Database Helpers
    
    func setupCurrentUser(completion: @escaping (_ completed:Bool) -> Void) {
        getUserDriver(withUID: USER_UID) { (driver) in
            
            UserDriver.currentUser = driver
            completion(true)
        }
    }
    
    func getInterval(withKey key: String, completion: @escaping (_ parkingInterval: ParkingInterval,_ snapshot:[String:AnyObject]) -> Void) {
        
        //Download the interval with key
        
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
    func getIntervalWithUpdates(withKey key: String, completion: @escaping (_ parkingInterval: ParkingInterval,_ snapshot:[String:AnyObject], _ handleKey:UInt, _ ref:FIRDatabaseReference) -> Void) {
        
        //Download the interval with key
        
        let ref = DataService.ds.REF_INTERVALS.child(key)
        var handle : UInt = 0
        
        handle = ref.observe(.value, with: { (snapshot) in
            
            guard let intervalData = snapshot.value as? Dictionary<String, AnyObject> else {
                HUD.flash(.labeledError(title: "Error", subtitle: "Parsing Interval Data into simple dictionary"), delay: 2.5)
                return
            }
            let parkingInterval = ParkingInterval(snapshot: intervalData)
            
            parkingInterval.intervalKey = key
            
            completion(parkingInterval,(snapshot.value as? [String: AnyObject])!, handle, ref)
            
        }, withCancel: { (error) in
            HUD.flash(.labeledError(title: "Downloading Error", subtitle: "Error with downloading interval data"), delay: 2.5)
        })
        
        
    }
    func getUserDriver(withUID key: String, completion: @escaping (_ userDriver: UserDriver) -> Void) {
        
        //Download the user with the UID
        
        DataService.ds.REF_USERS.child(key).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userData = snapshot.value as? Dictionary<String, AnyObject> else {
                HUD.flash(.labeledError(title: "Error", subtitle: "Parsing User Driver Data into simple dictionary"), delay: 2.5)
                return
            }
            
            let driver = UserDriver(snapshot: userData)
            completion(driver)

        })
        
    }
    func getUserDriverWithUpdates(withUID key: String, completion: @escaping (_ userDriver: UserDriver, _ handlerKey: UInt, _ ref:FIRDatabaseReference) -> Void) {
        
        //Download the user with the UID
        
        let ref = DataService.ds.REF_USERS.child(key)
        
        var handle: UInt = 0
        handle = ref.observe(.value, with: { (snapshot) in
            
            guard let userData = snapshot.value as? Dictionary<String, AnyObject> else {
                HUD.flash(.labeledError(title: "Error", subtitle: "Parsing User Driver Data into simple dictionary"), delay: 2.5)
                return
            }
            
            let driver = UserDriver(snapshot: userData)
            completion(driver,handle,ref)
            
        }) { (error) in
            HUD.flash(.labeledError(title: "Downloading Error", subtitle: "Error with downloading user driver with updates data"), delay: 2.5)
        }
        
    }
    func getParking(withKey key: String, completion: @escaping(_ parking: Parking) -> Void) {
        
        //Download the parking at the key
        
        DataService.ds.REF_PARKINGS.child(key).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let parkingData = snapshot.value as? Dictionary<String, AnyObject> else {
                HUD.flash(.labeledError(title: "Error", subtitle: "Parsing Parking Data into simple dictionary"), delay: 2.5)
                return
            }
            
            let parking = Parking(snapshot: parkingData)
            completion(parking)
            
        }) { (error) in
            
            HUD.flash(.labeledError(title: "Downloading Error", subtitle: "Error with downloading parking data"), delay: 2.5)
            
        }

    }
    func getParkingWithUpdates(withKey key: String, completion: @escaping(_ parking: Parking, _ handleKey:UInt, _ ref:FIRDatabaseReference) -> Void) {
        
        let ref = DataService.ds.REF_PARKINGS.child(key)
        
        //Download the parking at the key
        var handle: UInt = 0
        handle = ref.observe(.value, with: { (snapshot) in
            
            guard let parkingData = snapshot.value as? Dictionary<String, AnyObject> else {
                HUD.flash(.labeledError(title: "Error", subtitle: "Parsing Parking Data into simple dictionary"), delay: 2.5)
                return
            }
            
            let parking = Parking(snapshot: parkingData)
            completion(parking,handle,ref)
            
            
        }) { (error) in
            HUD.flash(.labeledError(title: "Downloading Error", subtitle: "Error with downloading parking with updates data"), delay: 2.5)
        }
        
    }
    func getUserInterval(withKey key: String, completion: @escaping(_ userInterval: UserInterval) -> Void ) {
        
        REF_USER_INTERVALS.child(key).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userIntervalData = snapshot.value as? Dictionary<String, AnyObject> else {
                HUD.flash(.labeledError(title: "Error", subtitle: "Parsing User Interval Data into simple dictionary"), delay: 2.5)
                return
            }
            
            let userInterval = UserInterval(snapshot: userIntervalData)
            completion(userInterval)
            
        }) { (error) in
            HUD.flash(.labeledError(title: "Downloading Error", subtitle: "Error with downloading user interval data"), delay: 2.5)
        }
        
    }
    
    
    
    //MARK: Downloading From Storage Helpers
    func uploadImage(withRef ref:FIRStorageReference, withImage image: UIImage, completion: @escaping (_ downloadURL: String) -> Void) {
        
        //Compress and setup the image data
        if let imgData = UIImageJPEGRepresentation(image, 0.1) {
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
    func downloadImage(withUrl url:String, completion: @escaping(_ image:UIImage) -> Void) {
        
        let ref = FIRStorage.storage().reference(forURL: url)
        
        ref.data(withMaxSize: 1024 * 1024) { (data, error) in
            if (error != nil) {
                HUD.flash(.labeledError(title: "Error", subtitle: "Downloading image data from firebase"), delay: 2.5)
            } else {
                guard let img = UIImage(data: data!) else {
                    HUD.flash(.labeledError(title: "Error", subtitle: "Converting Downloaded image from firebase"), delay: 2.5)
                    return
                }
                
                completion(img)
                
            }
        }
        
    }
    
    func createFirebaseDBUser(uid:String, userData: Dictionary<String,AnyObject>) {
        _REF_USERS.child(uid).updateChildValues(userData)
    }
    
    
    
    
}
