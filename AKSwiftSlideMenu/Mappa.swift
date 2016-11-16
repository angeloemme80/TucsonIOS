//
//  HomeVC.swift
//  AKSwiftSlideMenu
//
//  Created by MAC-186 on 4/8/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit
import GoogleMaps

class Mappa: BaseViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        // Do any additional setup after loading the view.
    }

    
    // You don't need to modify the default init(nibName:bundle:) method.
    
    override func loadView() {
        
        let locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        //var currentLocation = CLLocation!.self
        // Core Location Manager asks for GPS location
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.startMonitoringSignificantLocationChanges()
        
        let latitude = locManager.location?.coordinate.latitude
        let longitude = locManager.location?.coordinate.longitude
        print("latitude: \(latitude)")
        print("longitude: \(longitude)")
        
        var camera = GMSCameraPosition.camera(withLatitude: latitude!, longitude: longitude!, zoom: 6.0)
        var mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        mapView.isMyLocationEnabled = true
        view = mapView
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        marker.title = "my"
        marker.snippet = "mia posizione"
        marker.map = mapView
        
        //Abilito il bottone mylocation
        mapView.settings.myLocationButton = true
        
        
        
        

        
        
    }
}
