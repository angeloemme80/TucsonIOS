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
import Toaster


class Mappa: BaseViewController, CLLocationManagerDelegate, GMUClusterManagerDelegate, GMSMapViewDelegate {

    var managerPosizione: CLLocationManager!
    var posizioneUtente: CLLocationCoordinate2D!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var mapView:GMSMapView?=nil
    var markerViola:GMSMarker = GMSMarker()
    private var clusterManager: GMUClusterManager!
    var contatoreDistanzaMinoreDi = 0
    
    @IBOutlet weak var inviaPosizioneItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        if appDelegate.clickMenu == "mappa" {
            self.title = NSLocalizedString("tucson_map", comment:"")
        } else if appDelegate.clickMenu == "storico" {
            self.title = NSLocalizedString("historical", comment:"")
        }
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
        mapView?.delegate = self
        mapView?.isMyLocationEnabled = true
        view = mapView
        
        //Abilito il bottone mylocation
        mapView?.settings.myLocationButton = true
        //Nascondo il pulsante invia posizione
        self.navigationItem.rightBarButtonItem = nil
        
        //Aggiungo il marker viola che sarebbe la mia posizione attuale
        self.markerViola = GMSMarker()
        if(latitude != nil && longitude != nil){
            self.markerViola.position = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            self.markerViola.title = NSLocalizedString("my_position", comment:"")
            self.markerViola.snippet = NSLocalizedString("current_position", comment:"")
            self.markerViola.icon = GMSMarker.markerImage(with: UIColor.purple)
            self.markerViola.map = mapView
            
            //Abilito il pulsante di invio posizione
            self.navigationItem.rightBarButtonItem = self.inviaPosizioneItem
            
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
        //print(locations[0].coordinate.latitude.description + " - " + locations[0].coordinate.longitude.description)
        if ( self.posizioneUtente != nil ){
            let locazioneVecchia = CLLocation.init(latitude: self.posizioneUtente.latitude, longitude: self.posizioneUtente.longitude)
            let distanzaTra2Punti  = locazioneVecchia.distance(from: locations[0])
            //print ("distanzaTra2Punti:  \( distanzaTra2Punti)")
            if (distanzaTra2Punti < 5.0) {//Aggiorno il contatore, se per 50 volte la distanza è minore di 5 metri allora stoppo il listener, altrimenti faccio ripartire il contatore
                contatoreDistanzaMinoreDi += 1;
            } else {
                contatoreDistanzaMinoreDi = 0;
            }
            if (contatoreDistanzaMinoreDi >= 50) {
                managerPosizione.stopUpdatingLocation()//Fermo la ricerca continua della posizione
            }
        }
        
        self.posizioneUtente = locations[0].coordinate
        
        if(self.posizioneUtente != nil){//Se ottengo una nuova posizione, faccio refresh del marker viola
            self.markerViola.position = self.posizioneUtente
            //Abilito il pulsante di invio posizione
            self.navigationItem.rightBarButtonItem = self.inviaPosizioneItem
        }
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
        /*
        if( accessToken == nil || facebookId == nil){
            //vado alla view facebook per il login
            self.openViewControllerBasedOnIdentifier("FacebookVC")
            return ""
        }
 
        let parameters: Parameters = ["id": facebookId, "token": accessToken]
        
        // Define server side script URL
        let urlWithParams = appDelegate.urlServizio + "?id=\(facebookId!)&token=\(accessToken!)"
         */
        let urlWithParams = appDelegate.urlServizio + "no_auth"
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
    
    
    
    //FUNZIONE CHE RITORNA LE POSIZIONI INVIATE DA ME
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
        var slider = preferencesImpostazioni?.string(forKey: "slider")
        
        if( accessToken == nil || facebookId == nil){
            //vado alla view facebook per il login
            /*self.openViewControllerBasedOnIdentifier("FacebookVC")*/
            return ""
        }
        //let parameters: Parameters = ["id": facebookId, "token": accessToken]
        
        // Define server side script URL
        if slider == nil {
            slider = "999"
        }
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        let urlWithParams = appDelegate.urlServizio + facebookId! + "?token=\(accessToken!)&limite=\(slider!)&uuid=\(uuid)"
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
                            let titolo = NSLocalizedString("sent_on", comment:"")
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
    
    //FUNZIONE CHE CANCELLA LE POSIZIONI INVIATE DA ME
    func servizioPostDeletePositions(markerSnippet: String) -> String {
        let preferences = UserDefaults.init(suiteName: nomePreferenceFacebook)
        let preferencesImpostazioni = UserDefaults.init(suiteName: nomePreferenceImpostazioni)
        let accessToken = preferences?.string(forKey: "accessToken")
        let facebookId = preferences?.string(forKey: "facebookId")
        var slider = preferencesImpostazioni?.string(forKey: "slider")
        if slider == nil {
            slider = "999"
        }
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        let urlWithParams = appDelegate.urlServizio + facebookId! + "/DELETE"
        let urlStr : String = urlWithParams.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let myUrl = NSURL(string: urlStr as String);
        let request = NSMutableURLRequest(url:myUrl! as URL);
        request.httpMethod = "POST"
        let paramString = "token=\(accessToken!)&limite=\(slider!)&uuid=\(uuid)&positionDate=\(self.reimpostaFormatoData(dateString: markerSnippet))" as NSString
        request.httpBody = paramString.data(using: String.Encoding.utf8.rawValue)
        
        self.mapView?.clear() //Pulisco la mappa
        
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
                            let titolo = NSLocalizedString("sent_on", comment:"")
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
        
        return markerSnippet
    }
    
    
    
    //FUNZIONE DI INVIO POSIZIONE
    func servizioPostSendPositions() -> String {
        let preferences = UserDefaults.init(suiteName: nomePreferenceFacebook)
        let preferencesImpostazioni = UserDefaults.init(suiteName: nomePreferenceImpostazioni)
        let accessToken = preferences?.string(forKey: "accessToken")
        let facebookId = preferences?.string(forKey: "facebookId")
        let visualizzaEmail = ( (preferencesImpostazioni?.bool(forKey: "switchEmail"))! ? 1 : 0 )
        let visualizzaAnonimo = ( (preferencesImpostazioni?.bool(forKey: "switchAnonimo"))! ? 1 : 0 )
        
        let urlWithParams = appDelegate.urlServizio + facebookId!
        let urlStr : String = urlWithParams.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let myUrl = NSURL(string: urlStr as String);
        let request = NSMutableURLRequest(url:myUrl! as URL);
        request.httpMethod = "POST"
        let paramString = "token=\(accessToken!)&longitude=\(self.posizioneUtente.longitude)&latitude=\(self.posizioneUtente.latitude)&visualizza_mail=\(visualizzaEmail)&anonimo=\(visualizzaAnonimo)" as NSString
        request.httpBody = paramString.data(using: String.Encoding.utf8.rawValue)
        
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
                    let affectedRows = convertedJsonIntoDict.value(forKey: "affected_rows") as! NSNumber
                    if( affectedRows == 1 ){
                        Toast(text: NSLocalizedString("position_send", comment:"")).show()
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
        
        task.resume()
        
        return ""
    }
    
    
    //FUNZIONE DI INVIO POSIZIONE in modalità GUEST senza login facebook
    func servizioPostSendPositionsAsGuest() -> String {
        let preferences = UserDefaults.init(suiteName: nomePreferenceFacebook)
        let accessToken = preferences?.string(forKey: "accessToken")
        let facebookId = preferences?.string(forKey: "facebookId")
        let urlWithParams = appDelegate.urlServizio + "GUEST/" +  facebookId!
        let urlStr : String = urlWithParams.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let myUrl = NSURL(string: urlStr as String);
        let request = NSMutableURLRequest(url:myUrl! as URL);
        request.httpMethod = "POST"
        let paramString = "token=\(accessToken!)&longitude=\(self.posizioneUtente.longitude)&latitude=\(self.posizioneUtente.latitude)&visualizza_mail=&anonimo=" as NSString
        request.httpBody = paramString.data(using: String.Encoding.utf8.rawValue)
        
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
                    let affectedRows = convertedJsonIntoDict.value(forKey: "affected_rows") as! NSNumber
                    if( affectedRows == 1 ){
                        Toast(text: NSLocalizedString("position_send", comment:"")).show()
                    }
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
        
        task.resume()
        
        return ""
    }
    
    
    
    
    //Funzione di evento click sullinfowindow dwl marker
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        
        //Lancio un alert solo se siamo nello storico e se NON si tratta del marker viola quello della mia posizione attuale
        if (appDelegate.clickMenu == "storico" && marker.title != NSLocalizedString("my_position", comment:"")) {
            let cancellaAlert = UIAlertController(title: NSLocalizedString("del_position", comment:""), message: NSLocalizedString("delete_position", comment:""), preferredStyle: UIAlertControllerStyle.alert)
            
            cancellaAlert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment:""), style: .default, handler: { (action: UIAlertAction!) in
                print( self.servizioPostDeletePositions(markerSnippet: marker.snippet!) )
            }))
            
            cancellaAlert.addAction(UIAlertAction(title: NSLocalizedString("no", comment:""), style: .cancel, handler: { (action: UIAlertAction!) in
                print("NOOOOOO")
            }))
            
            present(cancellaAlert, animated: true, completion: nil)
        }
        
    }
    
    //Funzione per il cambio formato della data
    func cambioFormatoData(dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateObj = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        return dateFormatter.string(from: dateObj!)
    }
    
    //Funzione che reimposta il formato della data
    func reimpostaFormatoData(dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        let dateObj = dateFormatter.date(from: dateString)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: dateObj!)
    }
    
    
    //Evento del click sul pulsantino in alto a destra invia posizione
    @IBAction func clickInviaPosizioneItem(_ sender: Any) {
        
        let controller = UIAlertController(title: NSLocalizedString("send_position", comment:""),
                                       message: "",
                                       preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let azioneInviaPosizione = UIAlertAction(title: NSLocalizedString("send_position", comment:""), style: UIAlertActionStyle.default,
                                    handler: {(paramAction:UIAlertAction!) in
                                        
                                        //Lancio un alert se l'utente non è loggato
                                        let preferences = UserDefaults.init(suiteName: self.nomePreferenceFacebook)
                                        let accessToken = preferences?.string(forKey: "accessToken")
                                        let facebookId = preferences?.string(forKey: "facebookId")
                                        if( accessToken == nil || facebookId == nil){

                                            let loginAlert = UIAlertController(title: NSLocalizedString("send_position", comment:""), message: NSLocalizedString("login_message", comment:""), preferredStyle: UIAlertControllerStyle.alert)
                                        
                                            loginAlert.addAction(UIAlertAction(title: NSLocalizedString("yes", comment:""), style: .default, handler: { (action: UIAlertAction!) in
                                                self.openViewControllerBasedOnIdentifier("FacebookVC")
                                            }))
                                        
                                            loginAlert.addAction(UIAlertAction(title: NSLocalizedString("delete", comment:""), style: .destructive , handler: { (action: UIAlertAction!) in
                                                print("delete")
                                            }))
                                            
                                            self.present(loginAlert, animated: true, completion: nil)
                                            
                                        } else if (accessToken == "asGuest" && facebookId != nil) {
                                            if (self.posizioneUtente.latitude != 0 && self.posizioneUtente.longitude != 0){
                                                self.servizioPostSendPositionsAsGuest()
                                            }
                                        } else if (accessToken != nil && facebookId != nil) {
                                            if (self.posizioneUtente.latitude != 0 && self.posizioneUtente.longitude != 0){
                                                self.servizioPostSendPositions()
                                            }
                                        }
                                        
                                        
        })
        
        let azioneDestructive = UIAlertAction(title: NSLocalizedString("delete", comment:""), style: UIAlertActionStyle.destructive,
                                              handler: {(paramAction:UIAlertAction!) in
                                                // Distruggi tutto quello che hai inserito o modificato in questa istanza
                                                // Ovviamente devi essere tu a decidere cosa cancellare o no
                                                
        })
        
        
        controller.popoverPresentationController?.sourceView = self.view
                
        
        controller.addAction(azioneInviaPosizione)
        //controller.addAction(azioneInviaPosizioneAnonima)
        controller.addAction(azioneDestructive)
        
        self.present(controller, animated: true, completion: nil)
        
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

