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


class Mappa: BaseViewController, CLLocationManagerDelegate, GMUClusterManagerDelegate, GMSMapViewDelegate {

    var managerPosizione: CLLocationManager!
    var posizioneUtente: CLLocationCoordinate2D!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var mapView:GMSMapView?=nil
    var markerViola:GMSMarker = GMSMarker()
    private var clusterManager: GMUClusterManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        self.title = NSLocalizedString("tucson_map", comment:"")
    }

    
    // You don't need to modify the default init(nibName:bundle:) method.
    override func loadView() {
        
        managerPosizione = CLLocationManager()
        managerPosizione.delegate = self
        managerPosizione.requestWhenInUseAuthorization()
        managerPosizione.startUpdatingLocation()
        managerPosizione.desiredAccuracy = kCLLocationAccuracyBest
        //managerPosizione.startMonitoringSignificantLocationChanges()
        
        let latitude = managerPosizione.location?.coordinate.latitude
        let longitude = managerPosizione.location?.coordinate.longitude
        //print("latitude: \(latitude)")
        //print("longitude: \(longitude)")
        
        var camera:GMSCameraPosition
        if(latitude == nil || longitude == nil){//Se null allora mi posiziono sull'italia
            camera = GMSCameraPosition.camera(withLatitude: 41.900780, longitude: 12.483198, zoom: 6.0)
        } else {
            camera = GMSCameraPosition.camera(withLatitude: latitude!, longitude: longitude!, zoom: 6.0)
        }
        
        
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        mapView?.isMyLocationEnabled = true
        view = mapView
        
        //Abilito il bottone mylocation
        mapView?.settings.myLocationButton = true
        
        //Aggiungo il marker viola che sarebbe la mia posizione attuale
        self.markerViola = GMSMarker()
        if(latitude != nil && longitude != nil){
            self.markerViola.position = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            self.markerViola.title = NSLocalizedString("my_position", comment:"")
            self.markerViola.snippet = NSLocalizedString("current_position", comment:"")
            self.markerViola.icon = GMSMarker.markerImage(with: UIColor.purple)
            self.markerViola.map = mapView
        }
        
        //chiamo il servizio web in base al menu selezionato
        if appDelegate.clickMenu == "mappa" {
            servizioGetPositions(person: "Angelo")
        } else if appDelegate.clickMenu == "storico" {
            servizioGetIDPositions(person: "Angelo")
        }

    }
    
    
    //Funzione del locationManager che cerca sempre una nuova posizione
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        
        print(locations[0].coordinate.latitude.description + " - " + locations[0].coordinate.longitude.description)
        self.posizioneUtente = locations[0].coordinate
        
        if(self.posizioneUtente != nil){//Se ottengo una nuova posizione, faccio refresh del marker viola
            self.markerViola.position = self.posizioneUtente
        }
        //managerPosizione.stopUpdatingLocation()
    }
    
    
    
    //FUNZIONE CHE RITORNA LE POSIZIONE INVIATE DI TUTTI GLI UTENTI
    func servizioGetPositions(person: String) -> String {
        
        // Set up the cluster manager with the supplied icon generator and
        // renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView!, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView!, algorithm: algorithm, renderer: renderer)
        
        
        
        
        let preferences = UserDefaults.init(suiteName: nomePreferenceFacebook)
        let accessToken = preferences?.string(forKey: "accessToken")
        let facebookId = preferences?.string(forKey: "facebookId")
        if( accessToken == nil || facebookId == nil){
            //vado alla view facebook per il login
            self.openViewControllerBasedOnIdentifier("FacebookVC")
            return ""
        }
        let parameters: Parameters = ["id": facebookId, "token": accessToken]
        
        // Define server side script URL
        let urlWithParams = appDelegate.urlServizio + "?id=\(facebookId!)&token=\(accessToken!)"
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
            //let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            //print("responseString = \(responseString)")
            // Convert server json response to NSDictionary
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    let dic = convertedJsonIntoDict.value(forKey: "data") as! NSArray
                    //Scorro il dictionary "data" in un element che a sua volta è un dictionary
                    for element in dic {
                        let record = element as! NSDictionary
                        /*print(record["NAME"])
                        print(record["POSITION_DATE"])
                        print(record["LONGITUDE"])
                        print(record["LATITUDE"])*/
                        
                        DispatchQueue.main.async{
                            let marker = GMSMarker()
                            let lat = (record["LATITUDE"] as! NSString).doubleValue
                            let lon = (record["LONGITUDE"] as! NSString).doubleValue
                            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                            var titolo = ""
                            if(record["ANONIMO"] as! NSString == "1"){
                                marker.title = NSLocalizedString("anonymous", comment:"")
                                titolo = NSLocalizedString("anonymous", comment:"")
                            }else if(record["VISUALIZZA_MAIL"] as! NSString == "1"){
                                marker.title = (record["NAME"] as! NSString) as String + " - " + ((record["EMAIL"] as! NSString) as String) as String
                                titolo = (record["NAME"] as! NSString) as String + " - " + ((record["EMAIL"] as! NSString) as String) as String
                            } else {
                                marker.title = (record["NAME"] as! NSString) as String
                                titolo = (record["NAME"] as! NSString) as String
                            }
                            marker.snippet = self.cambioFormatoData(dateString: (record["POSITION_DATE"] as! NSString) as String)
                            marker.icon = GMSMarker.markerImage(with: UIColor.green)
                            marker.map = self.mapView
                            
                            let item = POIItem(position: CLLocationCoordinate2DMake(lat, lon), name: (record["NAME"] as! NSString) as String, titolo: titolo)
                            //self.clusterManager.add(item)
                            //self.clusterManager.cluster()
                            
                        }
                        
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
        
        task.resume()
        
        
        return appDelegate.urlServizio
    }
    
    
    
    //FUNZIONE CHE RITORNA LE POSIZIONE INVIATE DI TUTTI GLI UTENTI
    func servizioGetIDPositions(person: String) -> String {
        
        // Set up the cluster manager with the supplied icon generator and
        // renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView!, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView!, algorithm: algorithm, renderer: renderer)
        
        let preferences = UserDefaults.init(suiteName: nomePreferenceFacebook)
        let preferencesImpostazioni = UserDefaults.init(suiteName: nomePreferenceImpostazioni)
        let accessToken = preferences?.string(forKey: "accessToken")
        let facebookId = preferences?.string(forKey: "facebookId")
        let slider = preferencesImpostazioni?.string(forKey: "slider")
        if( accessToken == nil || facebookId == nil){
            //vado alla view facebook per il login
            self.openViewControllerBasedOnIdentifier("FacebookVC")
            return ""
        }
        //let parameters: Parameters = ["id": facebookId, "token": accessToken]
        
        // Define server side script URL
        let urlWithParams = appDelegate.urlServizio + facebookId! + "?token=\(accessToken!)&limite=\(slider!)"
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
            //let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            //print("responseString = \(responseString)")
            // Convert server json response to NSDictionary
            do {
                if let convertedJsonIntoDict = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    let dic = convertedJsonIntoDict.value(forKey: "data") as! NSArray
                    //Scorro il dictionary "data" in un element che a sua volta è un dictionary
                    for element in dic {
                        let record = element as! NSDictionary
                        /*print(record["NAME"])
                         print(record["POSITION_DATE"])
                         print(record["LONGITUDE"])
                         print(record["LATITUDE"])*/
                        
                        DispatchQueue.main.async{
                            let marker = GMSMarker()
                            let lat = (record["LATITUDE"] as! NSString).doubleValue
                            let lon = (record["LONGITUDE"] as! NSString).doubleValue
                            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                            var titolo = NSLocalizedString("sent_on", comment:"")
                            marker.title = titolo
                            
                            marker.snippet = self.cambioFormatoData(dateString: (record["POSITION_DATE"] as! NSString) as String)
                            marker.icon = GMSMarker.markerImage(with: UIColor.green)
                            marker.map = self.mapView
                            
                            let item = POIItem(position: CLLocationCoordinate2DMake(lat, lon), name: (record["ID"] as! NSString) as String, titolo: titolo)
                            //self.clusterManager.add(item)
                            //self.clusterManager.cluster()
                            
                        }
                        
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
        
        task.resume()
        
        
        return appDelegate.urlServizio
    }

    
    
    func cambioFormatoData(dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateObj = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        return dateFormatter.string(from: dateObj!)
    }
    
    

}

/// Point of Interest Item which implements the GMUClusterItem protocol.
class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var name: String!
    var titolo: String!
    
    init(position: CLLocationCoordinate2D, name: String, titolo: String) {
        self.position = position
        self.name = name
        self.titolo = titolo
    }
}

