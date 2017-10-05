//
//  SignInVC.swift
//  Viale
//
//  Created by Kai Nakamura on 5/24/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import UIKit
import Firebase
import PKHUD
import SwiftKeychainWrapper
import ImagePicker

var loggedInWithRegister = false

class SignInVC: UIViewController, ImagePickerDelegate {

    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var fullNameField: FancyField!
    @IBOutlet weak var phoneNumberField: FancyField!
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var passwordField: FancyField!
    @IBOutlet weak var selectCarImageButton: UIButton!
    @IBOutlet weak var selectAvatarImageButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    var selectedCarPicture = false
    var selectedAvatarPicture = false
    
    var carPicture: UIImage!
    var avatarPicture: UIImage!
    
    var selectingPictureIndex = 0
    var viewDidAppearOnce = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        //signOut()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (!self.viewDidAppearOnce) {
            if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
                HUD.show(.progress)
                DataService.ds.setupCurrentUser(completion: { (_,error) in
                    if (error) {
                        HUD.flash(.labeledError(title: "Logging In Error", subtitle: "There was an error with logging in"), delay: 2.0)
                        self.signOut()
                        return
                    }
                    HUD.hide()
                    self.performSegue(withIdentifier: "toMainScreen", sender: nil)
                })
            }
            self.viewDidAppearOnce = true
        }
    }
    
    func signOut() {
        KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        try! FIRAuth.auth()?.signOut()
        self.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }

    func setupRegisterView() {
        fullNameField.isHidden = false
        phoneNumberField.isHidden = false
        selectCarImageButton.isHidden = false
        selectAvatarImageButton.isHidden = false
        submitButton.setTitle("Register New Account", for: .normal)
    }
    func setupLoginView() {
        fullNameField.isHidden = true
        phoneNumberField.isHidden = true
        selectCarImageButton.isHidden = true
        selectAvatarImageButton.isHidden = true
        submitButton.setTitle("Login", for: .normal)
    }
    func loginUser() {
        
        guard let email = emailField.text, let password = passwordField.text else {
            return
        }
        if email == "" || password == "" {
            HUD.flash(.labeledError(title: "", subtitle: "Please fill out all email and password fields"), delay: 1.0)
            return
        }
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if (error != nil) {
                HUD.flash(.labeledError(title: "", subtitle: "There was an error logging in"), delay: 1.0)
            } else {
                if let user = user {
                    self.completeSignIn(id: user.uid, userData: [:])
                }
            }
        })
        
    }
    
    func registerUser() {
        
        guard let email = emailField.text, let password = passwordField.text, let fullName = fullNameField.text, let phoneNumber = phoneNumberField.text else {
            return
        }
        if email == "" || password == "" || fullName == "" || phoneNumber == "" {
            HUD.flash(.labeledError(title: "", subtitle: "Please fill out all email and password fields"), delay: 1.0)
            return
        }
        if selectedAvatarPicture == false {
            HUD.flash(.labeledError(title: "", subtitle: "Please choose a car image"), delay: 1.0)
            return
        }
        if selectedCarPicture == false {
            HUD.flash(.labeledError(title: "", subtitle: "Please choose an image of your car"), delay: 1.0)
            return
        }
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                HUD.flash(.labeledError(title: "", subtitle: "There was an error signing in"), delay: 1.0)
            } else {
                
                //First, compress and setup the data
                DataService.ds.uploadImage(withRef: DataService.ds.REF_CAR_IMAGES, withImage: self.carPicture, completion: { (carURL) in
                    
                    DataService.ds.uploadImage(withRef: DataService.ds.REF_AVATAR_IMAGES, withImage: self.avatarPicture, completion: { (avatarURL) in
                        
                        if let user = user {
                            let userData = ["fullName":fullName,"phoneNumber":phoneNumber,"hasDriveway":false,"carImageURL":carURL,"avatarImageURL":avatarURL] as [String : AnyObject]
                            self.completeSignIn(id: user.uid, userData: userData)
                        }
                        
                    })
                    
                })
                    
            }
            
        })
    }
    func completeSignIn(id: String, userData: Dictionary<String, AnyObject>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
        DataService.ds.setupCurrentUser(completion: { (_) in
            self.performSegue(withIdentifier: "toMainScreen", sender: nil)
            HUD.flash(.success, delay: 0.5)
            loggedInWithRegister = true
        })
    }
    
    @IBAction func segControlTapped(_ sender: Any) {
        
        if (segControl.selectedSegmentIndex == 0) {
            setupRegisterView()
        } else {
            setupLoginView()
        }
        
    }
    @IBAction func avatarImageButtonTapped(_ sender: Any) {
        
        selectingPictureIndex = 1
        
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
    @IBAction func carImageButtonTapped(_ sender: Any) {
        
        selectingPictureIndex = 2
        
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
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        
        if (segControl.selectedSegmentIndex == 0) {
            registerUser()
        } else {
            loginUser()
        }
        
    }
    
    //MARK: ImagePicker
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
    }
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        
        imagePicker.dismiss(animated: true, completion: nil)
        
        if selectingPictureIndex == 1 {
            selectedAvatarPicture = true
            avatarPicture = images[0]
            selectAvatarImageButton.setTitle("Avatar Picture Chosen", for: .normal)
            
        } else if selectingPictureIndex == 2 {
            selectedCarPicture = true
            carPicture = images[0]
            selectCarImageButton.setTitle("Car Picture Chosen", for: .normal)
        }
        
    }

}

