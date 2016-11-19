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
        
        
        
        if FBSDKAccessToken.current() != nil {
            //L'utente già possiede un access token
            self.logUserData()
        } else {
            let loginButton = FBSDKLoginButton()
            loginButton.readPermissions = ["public_profile", "email", "user_friends"]
            loginButton.center = self.view.center
            loginButton.delegate = self
            self.view.addSubview(loginButton)

        }
        
    }
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if (error == nil) {
            print("Utente connesso")
        } else
        {
            print(error.localizedDescription)
        }
    }
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logged out!")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.logUserData()
    }
    
    
    
    func logUserData(){
        /*let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "email, id, name, first_name, last_name, age_range, link, gender, locale, picture, timezone, updated_time, verified"] )
        graphRequest?.start(completionHandler: { (connection, result, error) -> Void in
            if error != nil {
                print(error)
            }else {
                print(result)
            }
        })*/
     
    
     
     
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

