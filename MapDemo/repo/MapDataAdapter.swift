//
//  MapDataAdapter.swift
//  MapDemo
//
//  Created by Rasmus Nielsen on 20/03/2020.
//  Copyright © 2020 Rasmus Nielsen. All rights reserved.
//

import Foundation
import FirebaseFirestore
import MapKit

class MapDataAdapter {
    
    static func getMKAnnotationsFromData(snap: QuerySnapshot) -> [MKPointAnnotation] {
        var markers = [MKPointAnnotation]() // Create an empty list
        var markerID = [String]()
        for doc in snap.documents {
            print("received data: ")
            let map = doc.data()
            
            let documentID = doc.documentID
            markerID.append(documentID)
            
            let text = map["text"] as! String
            print(text)
            let geoPoint = map["coordinates"] as! GeoPoint
            print(geoPoint)
            
            let mkAnnotation = MKPointAnnotation()  // Create new empty marker
            mkAnnotation.title = text               // Add title
            let coordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude) // Create coordinates
            mkAnnotation.coordinate = coordinate    // Add coordinates
            markers.append(mkAnnotation)            // Append the marker to the list of markers
        }
        return markers
    }
}
