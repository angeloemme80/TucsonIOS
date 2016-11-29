//
//  HomeVC.swift
//  AKSwiftSlideMenu
//
//  Created by MAC-186 on 4/8/16.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit
import GoogleMaps
import MapKit
import Alamofire

class Mappa: BaseViewController, CLLocationManagerDelegate {

    var managerPosizione: CLLocationManager!
    var posizioneUtente: CLLocationCoordinate2D!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        self.title = NSLocalizedString("tucson_map", comment:"")
    }

    
    // You don't need to modify the default init(nibName:bundle:) method.
    override func loadView() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        managerPosizione = CLLocationManager()
        managerPosizione.delegate = self
        managerPosizione.requestWhenInUseAuthorization()
        managerPosizione.startUpdatingLocation()
        managerPosizione.desiredAccuracy = kCLLocationAccuracyBest
        //managerPosizione.startMonitoringSignificantLocationChanges()
        
        let latitude = managerPosizione.location?.coordinate.latitude
        let longitude = managerPosizione.location?.coordinate.longitude
        print("latitude: \(latitude)")
        print("longitude: \(longitude)")
        
        if(latitude==nil || longitude == nil){
            return;
        }
        
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
        
        
        //chiamo il servizio web in base al menu selezionato
        if appDelegate.clickMenu == "mappa" {
            print(servizioGetPositions(person: "Angelo"))
        }

    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        print(locations[0].coordinate.latitude.description + " - " + locations[0].coordinate.longitude.description)
        self.posizioneUtente = locations[0].coordinate
        managerPosizione.stopUpdatingLocation()
    }
    
    func servizioGetPositions(person: String) -> String {
        let preferences = UserDefaults.init(suiteName: nomePreferenceFacebook)
        let accessToken = preferences?.string(forKey: "accessToken")
        let facebookId = preferences?.string(forKey: "facebookId")
        let parameters: Parameters = ["id": facebookId, "token": accessToken]
        
        // Define server side script URL
        let scriptUrl = "http://russoangela.altervista.org/TucsonREST_11/"
        let urlWithParams = scriptUrl + "?id=\(facebookId!)&token=\(accessToken!)"
        let myUrl = NSURL(string: urlWithParams);
        let request = NSMutableURLRequest(url:myUrl! as URL);
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            // Check for error
            if error != nil {
                print("error=\(error)")
                return
            }
            
            // Print out response string
            let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print("responseString = \(responseString)")
            // Convert server json response to NSDictionary
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    
                    // Print out dictionary
                    //print(convertedJsonIntoDict["data"])
                    let dic = convertedJsonIntoDict.value(forKey: "data") as! NSArray
                    //TODO Ho preso solo il primo, scorrerli tutti
                    print( dic.object(at: 0))
                        
                    
                    
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
        
        task.resume()
        
        return scriptUrl
    }
    
    /*
     func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
     self.posizioneUtente = userLocation.coordinate
     print("posizione aggiornata - lat: \(userLocation.coordinate.latitude) long: \(userLocation.coordinate.longitude)")
     let span = MKCoordinateSpanMake(0.05, 0.05)
     let region = MKCoordinateRegion(center: posizioneUtente, span: span)
     mapView.setRegion(region, animated: true)
     }*/
    
    
    
    
    
}
