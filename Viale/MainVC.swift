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
        
        testMyPin()
    }
    func testMyPin() {
        let testOwner = UserDriver(fullName: "Jackson Hurley", avatarImage: UIImage.init(named: "add_feeling_btn")!, carImage: UIImage.init(named: "Swift_logo.svg")!, phoneNumber: "1232456789")
        let testParking = Parking(addressString: "123 Alphabet Street", parkingImage: UIImage.init(named: "Swift_logo.svg")!, rating: 5.0, coordinate: CLLocationCoordinate2D.init(latitude: 34.4272373, longitude: -119.89878069999997), ratePerHour: 3, name: "The Best Parking Lot")
        let testParkingAnnotation = ParkingAnnotation()
        testParkingAnnotation.parking = testParking
        mapView.addAnnotation(testParkingAnnotation)
    }
    
    
    func setupNotifications() {
        
        //Logout Notification
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NOTIFICATION_KEY_LOGOUT_USER), object: nil, queue: nil) { (notification) in
            KeychainWrapper.standard.removeObject(forKey: KEY_UID)
            try! FIRAuth.auth()?.signOut()
            self.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: NOTIFICATION_KEY_MANAGE_DRIVEWAY), object: nil, queue: nil) { (notification) in

            self.performSegue(withIdentifier: "toManageDriveway", sender: nil)
            
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
            let annotationIndex = 1
            mapView.selectAnnotation(mapView.annotations[annotationIndex], animated: true)
            
            self.createSearchCircle(latitude: res.location.latitude, longitude: res.location.longitude)
        }
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
            
            selectedParking = parking
            
            //Download from firebase the owner data
            
            //Display the popup accordingly
            let popup = PopupDialog(title: "Dummy Name", message: parking.addressString)
            
            // Create buttons
            
            let buttonOne = DefaultButton(title: "PARK HERE ($\(String(describing: parking.ratePerHour!)) per hour)") {
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
            present(popup, animated: true, completion: nil)
            
            let vc = popup.viewController as! PopupDialogDefaultViewController
            
            // Set dialog properties
            vc.image = parking.parkingImage
            //vc.titleText = "Troll"
            //vc.messageText = "something"

        }
    }
    
    
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        
    }
    
    
    
}
