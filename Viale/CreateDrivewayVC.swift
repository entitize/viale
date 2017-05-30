//
//  CreateDrivewayVC.swift
//  Viale
//
//  Created by Kai Nakamura on 5/27/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import Foundation
import UIKit
import TextFieldEffects
import SwiftSignatureView
import ImagePicker
import PKHUD
import Firebase

class CreateDrivewayVC: UIViewController, SwiftSignatureViewDelegate, ImagePickerDelegate {
    
    var signed = false
    var selectedPicture = false
    
    @IBOutlet weak var nameField: HoshiTextField!
    @IBOutlet weak var addressField: HoshiTextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var signatureField: SwiftSignatureView!
    @IBOutlet weak var choosePictureButton: FancySubmitButton!
    
    var drivewayPicture : UIImage!
    var geoFire : GeoFire!
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        signatureField.clear()
        signed = false
    }
    
    override func viewDidLoad() {
        signed = false
        selectedPicture = false
        self.hideKeyboardWhenTappedAround()
        self.signatureField.delegate = self
        
        geoFire = GeoFire(firebaseRef: DataService.ds.REF_GEOFIRE)
    }
    
    @IBAction func choosePictureTapped(_ sender: Any) {
        var config = Configuration()
        config.doneButtonTitle = "Finish"
        config.noImagesTitle = "Sorry! There are no images here!"
        config.recordLocation = false
        
        let imagePicker = ImagePickerController()
        imagePicker.configuration = config
        imagePicker.imageLimit = 1
        imagePicker.delegate = self
        
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func createDrivewayTapped(_ sender: Any) {
        
        HUD.show(.labeledProgress(title: "Creating Your Driveway", subtitle: "Setting up awesomeness!"))
        
        
        if (nameField.text == "" || addressField.text == "" || descriptionTextField.text == "") {
            HUD.flash(.labeledError(title: "Fields", subtitle: "You must fill out all of the fields"), delay: 2.5)
            return
        }
        
        if (selectedPicture == false) {
            HUD.flash(.labeledError(title: "Image", subtitle: "You must select an image of your driveway"), delay: 2.5)
            return
        }
        
        if (signed == false) {
            HUD.flash(.labeledError(title: "Signature", subtitle: "You must sign in order to create your driveway"), delay: 2.5)
            return
        }
        
        let res = GoogleMapsService.gm.getLatLng(addressString: addressField.text!)
        if (res.isError) {
            HUD.flash(.labeledError(title: "Address", subtitle: "You must enter a valid address. It must be sufficently descriptive and accurate"), delay: 2.5)
            return
        }
        
        //Compress the image and upload
        if let imgData = UIImageJPEGRepresentation(drivewayPicture, 0.2) {
            let imageUID = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_PARKING_IMAGES.child(imageUID).put(imgData, metadata: metadata, completion: { (metadata, error) in
                if (error != nil) {
                    HUD.flash(.labeledError(title: "Error", subtitle: "There was an error with uploading the driveway image to the database"), delay: 2.5)
                } else {
                    
                    //Upload all the parking data to firebase
                    
                    //Finish configuring image
                    
                    if let downloadURL = metadata?.downloadURL()?.absoluteString {
                        
                        HUD.show(.labeledProgress(title: "Uploading Your Driveway", subtitle: "Almost there!"))
                        
                        //Create new object with key as user UID and object the GeoFire generated data
                        let location = CLLocation(latitude: res.location.latitude, longitude: res.location.longitude)
                        self.geoFire.setLocation(location, forKey: DataService.ds.USER_UID)
                        
                        //Create dictionary and add all the elements required
                        let parkingData: Dictionary<String, AnyObject> = [
                            "name":self.nameField.text as AnyObject,
                            "addressString": res.formattedAdress as AnyObject,
                            "parkingImageURL":downloadURL as AnyObject,
                            "description": self.descriptionTextField.text as AnyObject,
                            "totalStars":0 as AnyObject,
                            "totalRatings": 0 as AnyObject,
                            "totalRates": 0 as AnyObject,
                            "totalRatesAmount": 0 as AnyObject,
                            "ownerUID":DataService.ds.USER_UID as AnyObject,
                            "averageRate":0 as AnyObject
                        ]
                        
                        //Upload Driveway Information to firebase
                        let parkingPost = DataService.ds.REF_USER_PARKINGS
                        parkingPost.setValue(parkingData, withCompletionBlock: { (error, ref) in
                            
                            if (error != nil) {
                                HUD.flash(.labeledError(title: "Error", subtitle: "There was an error with uploading your driveway information"), delay: 2.5)
                            } else {
                                
                                DataService.ds.REF_USER_CURRENT.updateChildValues(["hasDriveway":true], withCompletionBlock: { (error, ref) in
                                    if (error != nil) {
                                        HUD.flash(.labeledError(title: "Error", subtitle: "There was an error with updating the user driveway status"), delay: 2.5)
                                    } else {
                                        HUD.flash(.success, delay: 1)
                                        self.dismiss(animated: true, completion: {
                                            NotificationCenter.default.post(name: NSNotification.Name.init(NOTIFICATION_KEY_DRIVEWAY_CREATED), object: nil)
                                        })
                                    }
                                })
                                
                            }
                            
                        })
                        
                        
                        
                    } else {
                        HUD.flash(.labeledError(title: "Error", subtitle: "There was an error with getting the image download URL"), delay: 3)
                    }
                    
                    
                }
            })
            
        }
        
        
        
    }
    
    //MARK: Signature
    func swiftSignatureViewDidPanInside(_ view: SwiftSignatureView) {
        signed = true
    }
    func swiftSignatureViewDidTapInside(_ view: SwiftSignatureView) {
        signed = true
    }
    
    //MARK: ImagePicker
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        selectedPicture = true
        imagePicker.dismiss(animated: true, completion: nil)
        drivewayPicture = images[0]
        choosePictureButton.setTitle("Picture Chosen", for: .normal)
        choosePictureButton.backgroundColor = UIColor.init(hex: "#A0D4FA")
    }
    
}
