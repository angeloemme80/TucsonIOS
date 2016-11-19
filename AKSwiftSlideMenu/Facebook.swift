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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSlideMenuButton()
        // Do any additional setup after loading the view.
        
        let loginButton = FBSDKLoginButton()
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        loginButton.center = self.view.center
        loginButton.delegate = self
        self.view.addSubview(loginButton)
        
        //esempio di lettura del preferences
        
        let preferences = UserDefaults.init(suiteName: "MyPrefsFile")
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
                let preferences = UserDefaults.init(suiteName: "MyPrefsFile")
                preferences?.set(token?.tokenString, forKey: "accessToken")
                preferences?.set(token?.userID, forKey: "facebookId")
                preferences?.synchronize()
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
        let preferences = UserDefaults.init(suiteName: "MyPrefsFile")
        preferences?.removeObject(forKey: "accessToken")
        preferences?.removeObject(forKey: "facebookId")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
     // MARK: - Navigation
     /*
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }*/
    
    
}

