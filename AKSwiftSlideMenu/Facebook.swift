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

class Facebook: BaseViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var buttonSkip: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        self.title = NSLocalizedString("facebook_login", comment:"")
        buttonSkip.setTitle(NSLocalizedString("skip_login", comment:""),for: .normal)
        
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.center = self.view.center
        loginButton.delegate = self
        self.view.addSubview(loginButton)
        
        //esempio di lettura del preferences
        let preferences = UserDefaults.init(suiteName: nomePreferenceFacebook)
        let accessToken = preferences?.string(forKey: "accessToken")
        print(accessToken)
        
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
        self.openViewControllerBasedOnIdentifier("MappaVC")
    }
    
     // MARK: - Navigation
     /*
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }*/
    
    
}

