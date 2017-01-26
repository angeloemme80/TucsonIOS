//
//  LoginSignin.swift
//  Tucson
//
//  Created by Angela Mac on 26/01/2017.
//  Copyright © 2017 Kode. All rights reserved.
//

import Foundation
import UIKit
import Toaster
import FBSDKCoreKit
import FBSDKLoginKit

class LoginSignin: BaseViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var buttonSignin: UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        
        
        username.placeholder = NSLocalizedString("username", comment:"")
        password.placeholder = NSLocalizedString("password", comment:"")
        email.placeholder = NSLocalizedString("email", comment:"")
        buttonLogin.setTitle(NSLocalizedString("login", comment:""),for: .normal)
        buttonSignin.setTitle(NSLocalizedString("signin", comment:""),for: .normal)
        
        //Intercetto se l'utente ha clikkato su login oppure signin e in base a ciò faccio vedere i campi opportuni
        if appDelegate.clickLoginSignin == "login" {
            self.title = NSLocalizedString("login", comment:"")
            buttonSignin.isHidden = true
            email.isHidden = true
        } else if appDelegate.clickLoginSignin == "signin" {
            self.title = NSLocalizedString("signin", comment:"")
            buttonLogin.isHidden = true
        }
        
        
        
    }
    
    @IBAction func tapLogin(_ sender: Any) {
        //Faccio il logout se necessario altrimenti faccio il login
        let preferences = UserDefaults.init(suiteName: self.nomePreferenceFacebook)
        if ( preferences?.string(forKey: "accessToken") == "asGuest" ){
            preferences?.removeObject(forKey: "accessToken")
            preferences?.removeObject(forKey: "facebookId")
            
            Toast(text: NSLocalizedString("logout_performed", comment:"")).show()
            return
        }
        
        //Effettuo il logout da facebook prima di fare il login come guest
        let loginManager = FBSDKLoginManager()
        loginManager.logOut() // this is an instance function
        
        
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        //print(uuid)
        
        let urlWithParams = appDelegate.urlServizio + "ID_FROM_UUID?token=asGuest&uuid=\(uuid)"
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
                    let idFromUuid = convertedJsonIntoDict.value(forKey: "id_from_uuid") as! NSString
                    let preferences = UserDefaults.init(suiteName: self.nomePreferenceFacebook)
                    preferences?.set("asGuest", forKey: "accessToken")
                    preferences?.set(idFromUuid, forKey: "facebookId")
                    preferences?.synchronize()
                    DispatchQueue.main.async{
                        Toast(text: NSLocalizedString("logged", comment:"")).show()
                        self.openViewControllerBasedOnIdentifier("MappaVC")
                    }
                    
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
        }
        
        task.resume()
        
        
    }
    
    @IBAction func tapSignin(_ sender: Any) {
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
