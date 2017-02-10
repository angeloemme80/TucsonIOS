//
//  Facebook.swift
//  AKSwiftSlideMenu
//
//  Created by Angela Mac on 11/11/2016.
//  Copyright © 2016 Kode. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Toaster

class Facebook: BaseViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var buttonSkip: UIButton!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        self.title = NSLocalizedString("facebook_login", comment:"")
        
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.center = self.view.center
        loginButton.delegate = self
        self.view.addSubview(loginButton)
        
        //esempio di lettura del preferences
        let preferences = UserDefaults.init(suiteName: nomePreferenceFacebook)
        //let accessToken = preferences?.string(forKey: "accessToken")
        //print(accessToken)
        if ( preferences?.string(forKey: "accessToken") == "asGuest" ){
            buttonSkip.setTitle(NSLocalizedString("logout", comment:""),for: .normal)
        } else {
            buttonSkip.setTitle(NSLocalizedString("login", comment:""),for: .normal)
        }
        
        buttonSignin.setTitle(NSLocalizedString("signin", comment:""),for: .normal)
        
    }
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if (error == nil) {
            print("Utente connesso")
            if FBSDKAccessToken.current() != nil {
                let token = FBSDKAccessToken.current()
                //print( token?.expirationDate )
                //print( token?.tokenString )
                //print( token?.userID )
                
                //Salvo nel NSUserDefaults
                let preferences = UserDefaults.init(suiteName: nomePreferenceFacebook)
                preferences?.set(token?.tokenString, forKey: "accessToken")
                preferences?.set(token?.userID, forKey: "facebookId")
                preferences?.synchronize()
                self.openViewControllerBasedOnIdentifier("MappaVC")
                return
            }
        } else {
            print(error.localizedDescription)
        }
    }
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logged out!")
        let preferences = UserDefaults.init(suiteName: nomePreferenceFacebook)
        preferences?.removeObject(forKey: "accessToken")
        preferences?.removeObject(forKey: "facebookId")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func tabSkipButton(_ sender: Any) {
        //Se "accessToken") == "asGuest" significa che già sono loggato quindi significa che ho cliccato su logout
        let preferences = UserDefaults.init(suiteName: nomePreferenceFacebook)
        if ( preferences?.string(forKey: "accessToken") == "asGuest" ){
            preferences?.removeObject(forKey: "accessToken")
            preferences?.removeObject(forKey: "facebookId")
            buttonSkip.setTitle(NSLocalizedString("login", comment:""),for: .normal)
        } else {
            appDelegate.clickLoginSignin = "login"
            self.openViewControllerBasedOnIdentifier("LoginSigninVC")
        }

        
        
        
    }
    
     // MARK: - Navigation
     /*
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }*/
    
    @IBOutlet weak var buttonSignin: UIButton!
    @IBAction func tapGoToSignin(_ sender: Any) {
        appDelegate.clickLoginSignin = "signin"
        self.openViewControllerBasedOnIdentifier("LoginSigninVC")
    }
    
}

