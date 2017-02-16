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
        
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
    }
    
    @IBAction func tapLogin(_ sender: Any) {
        
        //Effettuo il logout da facebook prima di fare il login come guest
        let loginManager = FBSDKLoginManager()
        loginManager.logOut() // this is an instance function
        
        
        let urlWithParams = appDelegate.urlServizio + "login"
        let urlStr : String = urlWithParams.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let myUrl = NSURL(string: urlStr as String);
        let request = NSMutableURLRequest(url:myUrl! as URL);
        request.httpMethod = "POST"
        let paramString = "username=\(username.text!)&userpassword=\(password.text!)" as NSString
        request.httpBody = paramString.data(using: String.Encoding.utf8.rawValue)

        
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
                    let status_code = convertedJsonIntoDict.value(forKey: "status_code") as! NSNumber
                    if(status_code==1200 || status_code==1650 ){
                        Toast(text: NSLocalizedString(status_code.stringValue, comment:"")).show()
                        return;
                    }
                    let userid = convertedJsonIntoDict.value(forKey: "userid") as! NSString
                    let username = convertedJsonIntoDict.value(forKey: "username") as! NSString
                    let useremail = convertedJsonIntoDict.value(forKey: "useremail") as! NSString
                    let preferences = UserDefaults.init(suiteName: self.nomePreferenceFacebook)
                    preferences?.set(username, forKey: "username")
                    preferences?.set(useremail, forKey: "useremail")
                    preferences?.set(userid, forKey: "facebookId")
                    preferences?.set("asGuest", forKey: "accessToken")
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
        
        let urlWithParams = appDelegate.urlServizio + "signin"
        let urlStr : String = urlWithParams.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let myUrl = NSURL(string: urlStr as String);
        let request = NSMutableURLRequest(url:myUrl! as URL);
        request.httpMethod = "POST"
        let paramString = "username=\(username.text!)&userpassword=\(password.text!)&useremail=\(email.text!)" as NSString
        request.httpBody = paramString.data(using: String.Encoding.utf8.rawValue)
        
        
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
                    let status_code = convertedJsonIntoDict.value(forKey: "status_code") as! NSNumber
                    if(status_code==1200 || status_code==1650 || status_code==2010 || status_code==2011 || status_code==2012 || status_code==2013 ){
                        Toast(text: NSLocalizedString(status_code.stringValue, comment:"")).show()
                        return;
                    }
                    let userid = convertedJsonIntoDict.value(forKey: "userid") as! NSString
                    let username = convertedJsonIntoDict.value(forKey: "username") as! NSString
                    let useremail = convertedJsonIntoDict.value(forKey: "useremail") as! NSString
                    let preferences = UserDefaults.init(suiteName: self.nomePreferenceFacebook)
                    preferences?.set(username, forKey: "username")
                    preferences?.set(useremail, forKey: "useremail")
                    preferences?.set(userid, forKey: "facebookId")
                    preferences?.set("asGuest", forKey: "accessToken")
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
    
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
