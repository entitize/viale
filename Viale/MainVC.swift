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
        
        geoSearchCircle(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude, radius: 2.5)
        
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        
        HUD.show(.labeledProgress(title: "Locating...", subtitle: "This may take a while"))
        
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        
        let res = GoogleMapsService.gm.getLatLng(addressString: searchBar.text!)
        if (res.isError) {
            HUD.flash(.labeledError(title: "Location was not found", subtitle: "Try being more descriptive or specific in your search."),delay:1.5)
        } else {
            HUD.hide()
            
            //Create the search annotation
            let searchAnnotation = SearchAnnotation()
            searchAnnotation.coord = res.location
            searchAnnotation.title = searchBar.text
            searchAnnotation.subtitle = res.formattedAdress
            mapView.addAnnotation(searchAnnotation)
            
            //Select the new annotation automatically
            //let annotationIndex = 1
            //mapView.selectAnnotation(mapView.annotations[annotationIndex], animated: true)
            
            //self.createSearchCircle(latitude: res.location.latitude, longitude: res.location.longitude)
            
            //Next, start GeoFire search
            geoSearchCircle(latitude: res.location.latitude, longitude: res.location.longitude,radius: 2.5)
            
            
        }
    }
    func geoSearchCircle(latitude:CLLocationDegrees,longitude:CLLocationDegrees,radius:Double) {
        
        
        let circleQuery = geoFire.query(at: CLLocation.init(latitude: latitude, longitude: longitude), withRadius: radius)
        
        circleQuery?.observe(GFEventType.keyEntered, with: { (key, location) in
            
            if let userUID = key, let location = location {
                
                //Download the parking information using the userID from 'parkings'
                
                
                DataService.ds.REF_PARKINGS.child(userUID).observeSingleEvent(of: .value, with: { (snap) in
                    
                    if let snapshot = snap.value as? [String: AnyObject] {
                        
                        //Parsing Data
                        guard let addressString = snapshot["addressString"] as? String, let description = snapshot["description"] as? String, let name = snapshot["name"] as? String, let parkingImageURL = snapshot["parkingImageURL"] as? String, let averageRate = snapshot["averageRate"] as? Float else {
                            
                            HUD.flash(.labeledError(title: "Parsing Error", subtitle: "EDBAG"), delay: 2.5)
                            return
                        }
                        
                        //Loop through the intervals and store them and put them inside parkingInformation
                        
                        var _intervals : [String: Bool]?
                        
                        if snap.hasChild("intervals") {
                            _intervals = snapshot["intervals"] as? [String: Bool]
                        } else {
                            _intervals = [:]
                        }
                        guard let intervals = _intervals else {
                            HUD.flash(.labeledError(title: "Internal Error", subtitle: "Error with parsing intervals"), delay: 2.5)
                            return
                        }
                        
                        //Download the image from parkingImageURL
                        let ref = FIRStorage.storage().reference(forURL: parkingImageURL)
                        ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                            if error != nil {
                                HUD.flash(.labeledError(title: "Downloading Image Error", subtitle: "Image"), delay: 2.5)
                            } else {
                                guard let data = data else {
                                    HUD.flash(.labeledError(title: "Downloading Image Error", subtitle: "Image"), delay: 2.5)
                                    return
                                }
                                guard let img = UIImage(data: data) else {
                                    return
                                }
                                
                                //Downloading Image Success
                                
                                //Set up parking object
                                let parking = Parking(addressString: addressString, parkingImage: img, rating: 5, coordinate: CLLocationCoordinate2D.init(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), name: name, totalIntervals: 100, description: description, averageRate: averageRate)
                                parking.ownerUID = userUID
                                parking.intervalKeys = []
                                
                                for interval in intervals {
                                    if (interval.value == true) {
                                        parking.intervalKeys.append(interval.key)
                                    }
                                }
                                
                                //Set up parking annotation
                                let parkingAnnotation = ParkingAnnotation()
                                parkingAnnotation.parking = parking
                                
                                if averageRate == 0 {
                                    parkingAnnotation.subtitle = "New Driveway! Not available for renting yet."
                                }
                                
                                //Finally, add the annotation
                                self.mapView.addAnnotation(parkingAnnotation)
                                
                                
                            }
                        })
                        
                        
                        
                        
                
                    } else {
                        HUD.flash(.labeledError(title: "Parsing Error", subtitle: "abcdefgh"), delay: 2.5)
                    }
                    
                    
                    
                }, withCancel: { (error) in
                    HUD.flash(.labeledError(title: "Error", subtitle: "Getting Parking Data Error"), delay: 2.5)
                })
                
                
            }
        })
    }
    
    func createSearchCircle(latitude:CLLocationDegrees,longitude:CLLocationDegrees) {
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
        self.centerMapOnLocation(location: location)
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
            
            RentService.rs.selectedParking = parking
            
            //Download from firebase the owner data
            DataService.ds.REF_USERS.child(parking.ownerUID!).child("fullName").observeSingleEvent(of: .value, with: { (snapshot) in
                if let fullName = snapshot.value as? String {
                    //Display the popup accordingly
                    let popup = PopupDialog(title: fullName, message: parking.addressString)
                    
                    // Create buttons
                    
                    let average = parking.averageRate!
                    
                    let buttonOne = DefaultButton(title: "RENT (Average: $\(average) / hour)") {
                        self.performSegue(withIdentifier: "toRent", sender: nil)
                    }
                    
                    let buttonTwo = DefaultButton(title: "BOOKMARK") {
                        //Bookmark code
                    }
                    
                    let buttonThree = CancelButton(title: "CANCEL", height: 60) { }
                    
                    // Add buttons to dialog
                    // Alternatively, you can use popup.addButton(buttonOne)
                    // to add a single button
                    popup.addButtons([buttonOne, buttonTwo, buttonThree])
                    self.present(popup, animated: true, completion: nil)
                    
                    let vc = popup.viewController as! PopupDialogDefaultViewController
                    
                    // Set dialog properties
                    vc.image = parking.parkingImage
                    
                    //vc.titleText = "Troll"
                    //vc.messageText = "something"
                }
            })
            
            

        }
    }
    
    
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        
    }
    
    
    
}
