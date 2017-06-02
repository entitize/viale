//
//  MainVC.swift
//  Viale
//
//  Created by Kai Nakamura on 5/25/17.
//  Copyright © 2017 Kai Nakamura. All rights reserved.
//

import Foundation
import UIKit
import SwiftKeychainWrapper
import Firebase
import PKHUD
import MapKit
import PopupDialog
import SwiftMessages

class MainVC : UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate {
    
    //IBOUTLETS Variables
    @IBOutlet weak var mapView: MKMapView!
    
    //GEOFIRE Variables
    var geoFire: GeoFire!
    
    //MAPKIT Variables
    let locationManager = CLLocationManager()
    var mapHasCenteredOnce = false
    
    //SEARCH Variables
    var searchController : UISearchController!
    
    override func viewDidLoad() {
        mapView.delegate = self
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        geoFire = GeoFire(firebaseRef: DataService.ds.REF_GEOFIRE)
        
        setupNotifications()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        mapHasCenteredOnce = false
        locationAuthStatus()
        
        if loggedInWithRegister == true {
            
            let popup = PopupDialog(title: "Welcome to Viale!", message: "Would you like a tour around the app?")
            
            let buttonOne = DefaultButton(title: "Yes please!") { }
            
            let buttonTwo = DefaultButton(title: "No thank you.") { }
            
            popup.addButtons([buttonOne, buttonTwo])
            self.present(popup, animated: true, completion: nil)
            
            loggedInWithRegister = false
        }
        
    }
    
    
    func setupNotifications() {
        
        //Logout Notification
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NOTIFICATION_KEY_LOGOUT_USER), object: nil, queue: nil) { (notification) in
            KeychainWrapper.standard.removeObject(forKey: KEY_UID)
            try! FIRAuth.auth()?.signOut()
            self.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
        //Manage Drive Notification
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NOTIFICATION_KEY_MANAGE_DRIVEWAY), object: nil, queue: nil) { (notification) in

            if UserDriver.currentUser.hasDriveway! {
                self.performSegue(withIdentifier: "toManageDriveway", sender: nil)
            } else {
                self.performSegue(withIdentifier: "toCreateDriveway", sender: nil)
            }
            
            
        }
        //Driveway Created Notification
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NOTIFICATION_KEY_DRIVEWAY_CREATED), object: nil, queue: nil) { (notification) in
            
            //Display the popup accordingly
            let popup = PopupDialog(title: "Success!", message: "Your driveway has been successfully created! Select 'Manage My Driveway' in the left sidebar to start renting your driveway to others!")
            
            // Create buttons
            let buttonOne = DefaultButton(title: "Done") { }
            
            popup.addButton(buttonOne)
            self.present(popup, animated: true, completion: nil)
            
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NOTIFICATION_KEY_EXIT_RENT), object: nil, queue: nil) { (notification) in
            
            //Display the popup accordingly
            
            
        }
    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            mapView.showsUserLocation = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 2000, 2000)
        
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let loc = userLocation.location {
            if !mapHasCenteredOnce {
                centerMapOnLocation(location: loc)
                mapHasCenteredOnce = true
            }
        }
    }
    
    
    @IBAction func searchFromLocal(_ sender: Any) {
        
        displaySerachingDialogue(titleText: "Searching...", bodyText: "Looking for nearby driveways from the center of the map")
        geoSearchCircle(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude, radius: 2.5)
        
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        
        let res = GoogleMapsService.gm.getLatLng(addressString: searchBar.text!)
        
        displaySerachingDialogue(titleText: "Searching...", bodyText: "Looking for nearby driveways from \(res.formattedAdress)")
        
        if (res.isError) {
            displayErrorDialogue(titleText: "Sorry", bodyText: "Please be more specific and accurate in your searching")
        } else {
            
            //Create the search annotation
            let searchAnnotation = SearchAnnotation()
            searchAnnotation.coord = res.location
            searchAnnotation.title = searchBar.text
            searchAnnotation.subtitle = res.formattedAdress
            mapView.addAnnotation(searchAnnotation)
            
            //Select the new annotation automatically
            mapView.selectAnnotation(searchAnnotation, animated: true)
            
            //Circle in on that search
            centerMapOnLocation(location: CLLocation(latitude: res.location.latitude, longitude: res.location.longitude))
            
            //Next, start GeoFire search
            geoSearchCircle(latitude: res.location.latitude, longitude: res.location.longitude,radius: 2.5)
            
        }
    }
    func displayErrorDialogue(titleText:String,bodyText:String) {
        let dialog = MessageView.viewFromNib(layout: .CardView)
        dialog.configureTheme(.error)
        dialog.configureDropShadow()
        dialog.configureContent(title: titleText, body: bodyText)
        dialog.button?.isHidden = true
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .bottom
        config.presentationContext = .window(windowLevel: UIWindowLevelNormal)
        SwiftMessages.show(config: config, view: dialog)
    }
    func displaySerachingDialogue(titleText:String,bodyText:String) {
        let dialog = MessageView.viewFromNib(layout: .CardView)
        dialog.configureTheme(.warning)
        dialog.configureDropShadow()
        dialog.configureContent(title: titleText, body: bodyText)
        dialog.button?.isHidden = true
        var config = SwiftMessages.defaultConfig
        config.duration = .forever
        config.presentationStyle = .bottom
        config.presentationContext = .window(windowLevel: UIWindowLevelNormal)
        SwiftMessages.show(config: config, view: dialog)
    }
    func displaySuccessSearchDialogue(foundCount:Int) {
        SwiftMessages.hide()
        let dialog = MessageView.viewFromNib(layout: .CardView)
        dialog.configureTheme(.success)
        dialog.configureDropShadow()
        dialog.configureContent(title: "Success!", body: "We found \(foundCount) nearby driveways!")
        dialog.button?.isHidden = true
        var config = SwiftMessages.defaultConfig
        config.presentationStyle = .bottom
        config.presentationContext = .window(windowLevel: UIWindowLevelNormal)
        SwiftMessages.show(config: config, view: dialog)
    }
    func geoSearchCircle(latitude:CLLocationDegrees,longitude:CLLocationDegrees,radius:Double) {
        
        //Clear any existing marks
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        var foundCount = 0
        
        let circleQuery = geoFire.query(at: CLLocation.init(latitude: latitude, longitude: longitude), withRadius: radius)
        
        let task = DispatchWorkItem {
            
            circleQuery?.removeAllObservers()
            SwiftMessages.hide()
            self.displayErrorDialogue(titleText: "Sorry", bodyText: "We could not find any nearby driveways")
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 6, execute: task)
        
        circleQuery?.observe(GFEventType.keyEntered, with: { (key, location) in
            
            if let userUID = key, let location = location {
                
                //Download the parking information
                foundCount += 1
                
                DataService.ds.getParking(withKey: userUID, completion: { (parking) in
                    
                    parking.coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    
                    //Set up parking annotation
                    let parkingAnnotation = ParkingAnnotation(parking: parking)
                    
                    if parking.averageRate == 0 {
                        parkingAnnotation.subtitle = "New Driveway! Not available for renting yet."
                    }
                    
                    //Finally, add the annotation
                    self.mapView.addAnnotation(parkingAnnotation)
                    
                })
  
            }
        })
        
        circleQuery?.observeReady({
            
            SwiftMessages.hide()
            
            task.cancel()
            
            if foundCount >= 1 {
                self.displaySuccessSearchDialogue(foundCount: foundCount)
            } else {
                self.displayErrorDialogue(titleText: "Sorry", bodyText: "We could not find any nearby driveways")
            }
            
            circleQuery?.removeAllObservers()
            
        })
        
    }
    
    func createSearchCircle(latitude:CLLocationDegrees,longitude:CLLocationDegrees) {
        
        let circle = MKCircle(center: CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude), radius: 500)
        mapView.add(circle)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleOverlay = overlay as? MKCircle
        let circleRenderer = MKCircleRenderer(overlay: circleOverlay!)
        circleRenderer.fillColor = UIColor.init(hex: "#F8BBD0")
        circleRenderer.alpha = 0.4
        return circleRenderer
        
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is SearchAnnotation {
            let pinAnnotationView = SearchAnnotationView(annotation: annotation, reuseIdentifier: "searchPin")
            return pinAnnotationView
        } else if annotation is ParkingAnnotation {
            let pinAnnotationView = ParkingAnnotationView(annotation: annotation, reuseIdentifier: "parkPin")
            return pinAnnotationView
        }
        return nil
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if view is ParkingAnnotationView {
            
            //Getting selected pin data
            let parkingAnnotationView : ParkingAnnotationView = view as! ParkingAnnotationView
            let parkingAnnotation : ParkingAnnotation = parkingAnnotationView.annotation as! ParkingAnnotation
            let parking : Parking = parkingAnnotation.parking!
            
            //Set the selected parking into future referencable variable
            RentService.rs.selectedParking = parking
            
            displaySerachingDialogue(titleText: "Loading Driveway...", bodyText: "")
            
            //Download from firebase the owner data
            DataService.ds.getUserDriver(withUID: parking.ownerUID!, completion: { (owner) in
                
                RentService.rs.selectedOwner = owner
            
                parking.getParkingImage(completion: { (image) in
                    
                    SwiftMessages.hide()
                    
                    //Display the popup accordingly
                    let popup = PopupDialog(title: owner.fullName, message: parking.addressString)
                    
                    let average = parking.averageRate!
                    
                    let buttonOne = DefaultButton(title: "RENT (Average: $\(average) / hour)") {
                        self.performSegue(withIdentifier: "toRent", sender: nil)
                    }
                    
                    let buttonTwo = DefaultButton(title: "BOOKMARK") { }
                    
                    let buttonThree = CancelButton(title: "CANCEL", height: 60) { }
                    
                    popup.addButtons([buttonOne, buttonTwo, buttonThree])
                    self.present(popup, animated: true, completion: nil)
                    
                    let vc = popup.viewController as! PopupDialogDefaultViewController
                    
                    vc.image = image
                    
                })
                
            })
            
        }
    }
 
}
