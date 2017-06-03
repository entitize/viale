//
//  UserDriver.swift
//  Viale
//
//  Created by Kai Nakamura on 5/26/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import Foundation

class UserDriver {
    
    static var currentUser : UserDriver!
    
    private var avatarImage : UIImage?
    
    var fullName : String!
    var phoneNumber : String!
    
    var avatarImageURL : String!
    var carImageURL : String!
    
    var hasDriveway : Bool!
    var scheduleKeys : [String]!
    
    init(snapshot:[String:AnyObject]) {
        
        if (snapshot.isEmpty) {
            return
        }
        
        self.fullName = snapshot["fullName"] as! String
        self.hasDriveway = snapshot["hasDriveway"] as! Bool
        self.phoneNumber = snapshot["phoneNumber"] as! String
        self.avatarImageURL = snapshot["avatarImageURL"] as! String
        self.carImageURL = snapshot["carImageURL"] as! String
        
        if let _schedule = snapshot["schedule"] as? [String:Bool] {
            self.scheduleKeys = []
            for (s,t) in _schedule {
                if (t == true) {
                    self.scheduleKeys.append(s)
                }
            }
        } else {
            self.scheduleKeys = []
        }
        
    }
    func getAvatarImage(completion: @escaping (_ image: UIImage) -> Void) {
        
        if let image = avatarImage {
            completion(image)
        } else {
            DataService.ds.downloadImage(withUrl: avatarImageURL, completion: { (image) in
                self.avatarImage = image
                completion(image)
            })
            
        }
        
        
    }
    
    
    
}
