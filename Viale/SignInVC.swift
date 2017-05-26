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

class SignInVC: UIViewController {

    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var fullNameField: FancyField!
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var passwordField: FancyField!
    @IBOutlet weak var submitButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SignInVC.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "toMainScreen", sender: nil)
        }
    }

    func setupRegisterView() {
        fullNameField.isHidden = false
        submitButton.setTitle("Register New Account", for: .normal)
    }
    func setupLoginView() {
        fullNameField.isHidden = true
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
                    let userData = ["provider":user.providerID]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
        
    }
    
    func registerUser() {
        guard let email = emailField.text, let password = passwordField.text, let fullName = fullNameField.text else {
            return
        }
        if email == "" || password == "" || fullName == "" {
            HUD.flash(.labeledError(title: "", subtitle: "Please fill out all email and password fields"), delay: 1.0)
            return
        }
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                HUD.flash(.labeledError(title: "", subtitle: "There was an error signing in"), delay: 1.0)
            } else {
                if let user = user {
                    let userData = ["provider":user.providerID,"fullName":fullName]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
                
            }
        })
    }
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
        performSegue(withIdentifier: "toMainScreen", sender: nil)
        HUD.flash(.success, delay: 0.5)
    }
    
    @IBAction func segControlTapped(_ sender: Any) {
        
        if (segControl.selectedSegmentIndex == 0) {
            setupRegisterView()
        } else {
            setupLoginView()
        }
        
    }
    @IBAction func submitButtonTapped(_ sender: Any) {
        
        HUD.show(.progress)
        
        if (segControl.selectedSegmentIndex == 0) {
            registerUser()
        } else {
            loginUser()
        }
        
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }


}

