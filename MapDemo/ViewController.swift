//
//  ViewController.swift
//  MapDemo
//
//  Created by Rasmus Nielsen on 20/03/2020.
//  Copyright © 2020 Rasmus Nielsen. All rights reserved.
//

import UIKit
import MapKit
import FirebaseFirestore
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var map: MKMapView!
    
    let locationManager = CLLocationManager() // Will handle Location (GPS/WIFI) updates
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the current location of the user
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // Ask for permission to use location
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer  // How precise do you want the tracking to be?
        locationManager.startUpdatingLocation()     // Start to track the user
        map.showsUserLocation = true        // Display the dot for the user
        
        // if you want to stop tracking
        //locationManager.stopUpdatingLocation()
        
        createMarkers()
        
        // Add the ability to long press the screen to add a new pin
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        longTapGesture.delegate = self as? UIGestureRecognizerDelegate
        map.addGestureRecognizer(longTapGesture)
        
        // FIREBASE
        // Start the listener
        FirebaseRepo.startListener(vc: self)
        
    }
    
    // Method to handle long press add marker
    @objc func longTap(_ gestureReconizer: UILongPressGestureRecognizer) -> String
    {
        
        let location = gestureReconizer.location(in: map)
        let coordinate = map.convert(location,toCoordinateFrom: map)

        // Add the pop up alert to get user input
        var desiredname = ""
        let alert = UIAlertController(title: "Name of place", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input the name here..."
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            
            if let name = alert.textFields?.first?.text {
                print("Name of place: \(name)")
                desiredname = name
                // Add annotation:
                let annotation = MKPointAnnotation()
                annotation.title = desiredname
                print("Testing title: \(desiredname)")
                annotation.coordinate = coordinate
                self.map.addAnnotation(annotation)
                
                // Save the marker to firebase
                FirebaseRepo.saveMarker(marker: annotation)
                
            }
        }))
        
        self.present(alert, animated: true)
    
        
        return desiredname
    }
    
    
    func mapView(map: MKMapView, didTapMarker marker: MKPointAnnotation) -> Bool {
        print("tapped on marker")
        print("Name: \(marker.title ?? "NoName")")
        if marker.title == "Me"{
            print("handle specific marker")
        }
        return true
    }
 
    
    // Firebase
    func updateMarkers(snap: QuerySnapshot) {
        let markers = MapDataAdapter.getMKAnnotationsFromData(snap: snap)   //Call adapter to convert data
        print("updating markers...")
        // Make a loop, iterating over each marker in the list
        map.removeAnnotations(map.annotations)    // Clear the map before we add markers again
        map.addAnnotations(markers)               // Add markers from Firebase
        
    }
    
    fileprivate func createMarkers() {
        // Make marker
        let marker = MKPointAnnotation() // Create empty marker
        marker.title = "Go here"         // Add title
        // Create the coordinates for the marker to be fixed upon
        let location = CLLocationCoordinate2D(latitude: 55.7, longitude: 12.5)  // Coordinates for Denmark
        marker.coordinate = location // Add the location to the marker
        
        // Enable the user to add a marker
        // Is a read marker, where the user can click for more info
        map.addAnnotation(marker)
        
        // Add second marker for Pizzaria
        let markerPizza = MKPointAnnotation()
        markerPizza.title = "Non Solo"
        let locationPizza = CLLocationCoordinate2D(latitude: 55.688081, longitude: 12.560509)
        markerPizza.coordinate = locationPizza
        
        map.addAnnotation(markerPizza)
        
        // Add third marker for venue
        let markerVenue = MKPointAnnotation()
        markerVenue.title = "VEGA"
        let locationVenue = CLLocationCoordinate2D(latitude: 55.668222, longitude: 12.544246)
        markerVenue.coordinate = locationVenue
        
        map.addAnnotation(markerVenue)
    }


}

// Extension
// The cool thing about an extension is that every class can extend it?
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("new location: \(locations.first?.coordinate)")
        // Move the map view to the location
        if let coordinate = locations.last?.coordinate {
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
            map.setRegion(region, animated: true)
        }
    }
    
}
