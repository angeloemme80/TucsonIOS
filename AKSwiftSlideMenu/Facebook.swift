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
            loginButton.center = self.view.center
            loginButton.readPermissions = ["email", "public_profile","user_friends"]
            self.view.addSubview(loginButton)
            loginButton.delegate = self

        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.logUserData()
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("logged in!")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logged out!")
    }
    
    func logUserData(){
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil )
        graphRequest?.start(completionHandler: { (connection, result, error) -> Void in
            if error != nil {
                print(error)
            }else {
                print(result)
            }
        })
        
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

