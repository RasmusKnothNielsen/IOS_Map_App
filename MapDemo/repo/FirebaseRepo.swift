//
//  FirebaseRepo.swift
//  MapDemo
//
//  Created by Rasmus Nielsen on 20/03/2020.
//  Copyright © 2020 Rasmus Nielsen. All rights reserved.
//

// This app is using Firebase-App

import Foundation
// Importing the cloud database
import FirebaseFirestore

import MapKit

class FirebaseRepo {
    
    // Getting the instance of the database
    private static let db = Firestore.firestore()
    // Name of collection on firestore
    private static let path = "locations"
    
    static func startListener(vc: ViewController) {
        print("listener started...")
        // When there is a result, call
        //vc.updateMarkers()
        db.collection(path).addSnapshotListener { (snap, error) in
            if error != nil {   // Check if there is an error and abort if so
                return
            }
            if let snap = snap {    // Check if the snap has a value
                vc.updateMarkers(snap: snap)
            }
        }
        
    }
    
    //CRUD
    // Create
    static func saveMarker(marker: MKPointAnnotation) {
        // Add a new document in collection "locations"
        let coordinates = GeoPoint(latitude: marker.coordinate.latitude, longitude: marker.coordinate.longitude)
        db.collection(path).document().setData([
            "coordinates": coordinates,
            "text": marker.title ?? "NoName",
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    static func getDocumentID(name: String) -> String {
        var result = ""
        db.collection(path).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                for doc in querySnapshot!.documents {
                    let map = doc.data()
                    
                    let documentID = doc.documentID
                    
                    let text = map["text"] as! String
                    if text == name {
                        result = documentID
                    }
                    
                }
            }
        }
        return result
    }
    
    static func deleteMarker(marker: MKPointAnnotation) {
        
        let docId = getDocumentID(name: marker.title!)
        db.collection(path).document(docId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    
}
